#include "opendefs.h"
#include "IEEE802154E.h"
#include "openserial.h"
#include "openqueue.h"
#include "packetfunctions.h"
#include "sixtop.h"
#include "idmanager.h"
#include "opentimers.h"
#include "scheduler.h"
#include "center_schedule.h"
#include "center_schedule_root.h"
#include "center_schedule_leader.h"
#include "center_schedule_member.h"
#include "center_schedule_tasks.h"

// Debug macro, output debug information when DEBUG_DETAIL is 1
#if DEBUG_DETAIL
#define DEBUG_PRINTF(fmt, ...) openserial_mysf_printf(fmt, ##__VA_ARGS__)
#else
#define DEBUG_PRINTF(fmt, ...) 
#endif

// Global variable declaration
static leader_tasks_t leader_tasks_vars;
static member_tasks_t member_tasks_vars;
static root_tasks_t root_tasks_vars;

extern root_vars_t root_vars;
extern leader_vars_t leader_vars;
extern member_vars_t member_vars;

static task_queue_t queue;

task_struct tasks[MAX_TASKS_PER_LEADER * MAX_LEADERS]; // Instance storage.

// 预定义任务表
static task_struct predefined_tasks[] = {
    // 厨房监控任务 - IO密集型
    {
        .taskID = TASK_ID_KITCHEN_MONITOR,
        .type = {
            .attr = IO_INTENSIVE,
            .class = KITCHEN
        },
        .constraint = {
            .data.io = {
                .target = 5,       /* 监控5个目标点 */
                .threshold = 10    /* 温度阈值10度 */
            }
        },
        .leaderID = 0xFF,          /* 初始未分配 */
        .progress = 0,
        .active = FALSE,
        .compatibleMask = (1 << TASK_ID_PATROL_REGULAR) | (1 << TASK_ID_PATROL_INTENSIVE)  /* 可与巡逻任务并行 */
    },
    
    // 厨房火灾检测任务 - IO密集型
    {
        .taskID = TASK_ID_KITCHEN_FIRE_DETECT,
        .type = {
            .attr = IO_INTENSIVE,
            .class = KITCHEN
        },
        .constraint = {
            .data.io = {
                .target = 3,       /* 监控3个目标点 */
                .threshold = 50    /* 温度阈值50度 */
            }
        },
        .leaderID = 0xFF,
        .progress = 0,
        .active = FALSE,
        .compatibleMask = (1 << TASK_ID_PATROL_REGULAR)  /* 只能与常规巡逻任务并行 */
    },
    
    // 巡逻任务 - CPU密集型
    {
        .taskID = TASK_ID_PATROL_REGULAR,
        .type = {
            .attr = CPU_INTENSIVE,
            .class = PATROL
        },
        .constraint = {
            .data.cpu = {
                .frequency = 5,    /* 每5秒执行一次 */
                .duration = 20     /* 持续20秒 */
            }
        },
        .leaderID = 0xFF,
        .progress = 0,
        .active = FALSE,
        .compatibleMask = (1 << TASK_ID_KITCHEN_MONITOR) | (1 << TASK_ID_KITCHEN_FIRE_DETECT)  /* 可与厨房监控任务并行 */
    },
    
    // 高频巡逻任务 - CPU密集型
    {
        .taskID = TASK_ID_PATROL_INTENSIVE,
        .type = {
            .attr = CPU_INTENSIVE,
            .class = PATROL
        },
        .constraint = {
            .data.cpu = {
                .frequency = 2,    /* 每2秒执行一次 */
                .duration = 30     /* 持续30秒 */
            }
        },
        .leaderID = 0xFF,
        .progress = 0,
        .active = FALSE,
        .compatibleMask = (1 << TASK_ID_KITCHEN_MONITOR)  /* 只能与厨房监控任务并行 */
    }
};
/**
 * Initialize the root node task management system
 */
void root_initTaskHandler() {
    uint8_t i, j;
    root_tasks_t *root_tasks = &root_tasks_vars;
    
    DEBUG_PRINTF("root_initTaskHandler: Starting to initialize root node task management system");
    
    // Initialize system-level counters
    root_tasks->activeTaskCount = 0;
    root_tasks->queuedTaskCount = 0;
    root_tasks->max_queued = MAX_QUEUED_TASKS;
    
    DEBUG_PRINTF("root_initTaskHandler: System-level counter initialization complete");

    // Initialize task storage instances
    for(i = 0; i < MAX_TASKS_PER_LEADER * MAX_LEADERS; i++){
        tasks[i].taskID = 0;
        tasks[i].active = FALSE;
        tasks[i].progress = 0;
        tasks[i].leaderID = 0;
        tasks[i].compatibleMask = 0;
        tasks[i].type.attr = 0;
        tasks[i].type.class = 0;
        
        for(uint8_t j = 0; j < MAX_SLOTS_PER_TASK; j++) {
            tasks[i].resource[j] = NULL;
        }
    }
    
    DEBUG_PRINTF("root_initTaskHandler: Task storage instances initialization complete");

    // Initialize task management for each leader
    for (i = 0; i < MAX_LEADERS; i++) {
        // Reset counters
        root_tasks->leaders[i].taskCount = 0;
        root_tasks->leaders[i].queuedTaskCount = 0;
        root_tasks->leaders[i].completedTaskCount = 0;
        root_tasks->leaders[i].failedTaskCount = 0;
        root_tasks->leaders[i].max_active = MAX_TASKS_PER_LEADER;
        root_tasks->leaders[i].leader = &root_vars.leaders[i];
        // Set supported task categories based on leader ID (even IDs support KITCHEN, odd IDs support PATROL)
        root_tasks->leaders[i].class = (i % 2 == 0) ? KITCHEN : PATROL;
        
        // Initialize task array
        for (j = 0; j < MAX_TASKS_PER_LEADER; j++) {
            root_tasks->leaders[i].tasks[j] = NULL;
        }
    }
    
    DEBUG_PRINTF("root_initTaskHandler: Leader task management initialization complete");
    
    task_queue_init(&queue);
    
    DEBUG_PRINTF("root_initTaskHandler: Queue initialization complete");
}

uint8_t root_taskChooseLeader(task_class class, uint8_t taskID) {
    uint8_t i;
    uint8_t bestLeader = 0xFF;  // Invalid initial value
    uint8_t minTaskCount = 0xFF;
    
    DEBUG_PRINTF("root_taskChooseLeader: Starting to find suitable leader, task class: %d", class);
    
    // 1.Traverse leader list, select leaders that support the task and have no conflicting tasks
    for (i = 0; i < MAX_LEADERS; i++) {
        bool supportTask = FALSE;
        bool hasConflict = FALSE;
        uint8_t j;
        
        //DEBUG_PRINTF("root_taskChooseLeader: Checking leader ID: %d", i);
        
        // Check if leader supports this type of task
        for (j = 0; j < MAX_TASKS_PER_LEADER; j++) {
            if (root_tasks_vars.leaders[i].class == class && root_tasks_vars.leaders[i].taskCount < MAX_TASKS_PER_LEADER) {
                supportTask = TRUE;
                //DEBUG_PRINTF("root_taskChooseLeader: Leader %d supports this task type", i);
                break;
            }
        }
        
        if (!supportTask) {
            //DEBUG_PRINTF("root_taskChooseLeader: Leader %d does not support this task type, skipping", i);
            continue;
        }
        
        // Check if leader has conflicting tasks
        for (j = 0; j < root_tasks_vars.leaders[i].taskCount; j++) {
            
            // Check if new task is compatible with current active tasks
            if (root_tasks_vars.leaders[i].tasks[j]->active) {
                // Check compatibility mask, if current task's compatibility mask doesn't include new task, there's a conflict
                if ((root_tasks_vars.leaders[i].tasks[j]->compatibleMask & (1 << taskID)) == 0) {
                    hasConflict = TRUE;
                    //DEBUG_PRINTF("root_taskChooseLeader: Leader %d has conflict with task %d", i, taskID);
                    break;
                }
            }
        }
        
        if (hasConflict) {
            //DEBUG_PRINTF("root_taskChooseLeader: Leader %d has conflicting tasks, skipping", i);
            continue;
        }
        
        // 2.Select the most idle leader from those supporting the task
        uint8_t totalTasks = root_tasks_vars.leaders[i].taskCount + root_tasks_vars.leaders[i].queuedTaskCount;
        if (totalTasks < minTaskCount) {
            minTaskCount = totalTasks;
            bestLeader = i;
            //DEBUG_PRINTF("root_taskChooseLeader: Updated best leader to %d, current task count %d", i, totalTasks);
        }
    }
    

    // 3.If result is empty, return invalid value
    DEBUG_PRINTF("root_taskChooseLeader: Final selected leader ID: %d", bestLeader);
    return bestLeader;  // Return leader ID, or 0xFF if none
}

resource_desc_t root_calcTaskResource(uint8_t leader, task_attribute attr, task_constraint* constraint) {
    resource_desc_t resourceDesc;
    
    DEBUG_PRINTF("root_calcTaskResource: Starting to calculate task resource requirements - Leader ID: %d, Task attribute: %d", leader, attr);
    
    //openserial_root_printf("Starting to calculate task resource requirements - Leader ID: %d, Task attribute: %d", leader, attr);
    
    // 1.Calculate required resources based on task attributes and performance constraints
    if (attr == CPU_INTENSIVE) {
        // For CPU-intensive tasks
        resourceDesc.numSlots = constraint->data.cpu.frequency * constraint->data.cpu.duration / 10;  // Simplified calculation
        resourceDesc.numMembers = constraint->data.cpu.duration / 5;  // Simplified calculation
        
        DEBUG_PRINTF("root_calcTaskResource: CPU intensive task - Frequency: %d, Duration: %d", 
                   constraint->data.cpu.frequency, 
                   constraint->data.cpu.duration);
        
        // openserial_root_printf("CPU intensive task - Frequency: %d, Duration: %d", 
        //                      constraint->data.cpu.frequency, 
        //                      constraint->data.cpu.duration);
    } else if (attr == IO_INTENSIVE) {
        // For IO-intensive tasks
        resourceDesc.numSlots = constraint->data.io.target * constraint->data.io.threshold / 20;  // Simplified calculation
        resourceDesc.numMembers = constraint->data.io.target / 10;  // Simplified calculation
        
        DEBUG_PRINTF("root_calcTaskResource: IO intensive task - Target: %d, Threshold: %d", 
                   constraint->data.io.target, 
                   constraint->data.io.threshold);
        
        // openserial_root_printf("IO intensive task - Target: %d, Threshold: %d", 
        //                      constraint->data.io.target, 
        //                      constraint->data.io.threshold);
    } else {
        // Unknown type, return 0 resources
        resourceDesc.numSlots = 0;
        resourceDesc.numMembers = 0;
        
        DEBUG_PRINTF("root_calcTaskResource: Warning - Unknown task type");
        
        //openserial_root_printf("Warning: Unknown task type");
    }
    
    DEBUG_PRINTF("root_calcTaskResource: Initial resource calculation - Slots: %d, Members: %d", 
               resourceDesc.numSlots, 
               resourceDesc.numMembers);
    
    // openserial_root_printf("Initial resource calculation - Slots: %d, Members: %d", 
    //                      resourceDesc.numSlots, 
    //                      resourceDesc.numMembers);
    
    // Ensure at least 1 slot and 1 member
    if (resourceDesc.numSlots == 0) {
        resourceDesc.numSlots = 1;
        
        DEBUG_PRINTF("root_calcTaskResource: Slot count adjusted to 1");
        
        //openserial_root_printf("Slot count adjusted to 1");
    }
    if (resourceDesc.numMembers == 0) {
        resourceDesc.numMembers = 1;
        
        DEBUG_PRINTF("root_calcTaskResource: Member count adjusted to 1");
        
        //openserial_root_printf("Member count adjusted to 1");
    }
    
    // 3.Subtract leader's current resources from total to get remaining resources
    DEBUG_PRINTF("root_calcTaskResource: Leader current slot count: %d", root_vars.leaders[leader].resource.numSlots);
    
    // openserial_root_printf("Leader current slot count: %d", root_vars.leaders[leader].resource.numSlots);
    if (resourceDesc.numSlots <= root_vars.leaders[leader].resource.numSlots) {
        resourceDesc.numSlots = 0;
        
        DEBUG_PRINTF("root_calcTaskResource: Leader has enough resources, no additional allocation needed");
        
        //openserial_root_printf("Leader has enough resources, no additional allocation needed");
    } else {
        resourceDesc.numSlots -= root_vars.leaders[leader].resource.numSlots;
        
        DEBUG_PRINTF("root_calcTaskResource: Need additional slot allocation: %d", resourceDesc.numSlots);
        
        //openserial_root_printf("Need additional slot allocation: %d", resourceDesc.numSlots);
    }
    
    DEBUG_PRINTF("root_calcTaskResource: Final resource requirements - Slots: %d, Members: %d", 
               resourceDesc.numSlots, 
               resourceDesc.numMembers);
    
    // openserial_root_printf("Final resource requirements - Slots: %d, Members: %d", 
    //                      resourceDesc.numSlots, 
    //                      resourceDesc.numMembers);
    
    return resourceDesc;
}

bool root_getResourceSendTask(uint8_t leader, task_struct* task, resource_desc_t resourceDesc, root_slot_resource_t *resource) {
    uint8_t i, j, count = 0;
    uint8_t channelsPerSlot = MAX_CHANNELS_PER_SLOT; // Number of channels to select per slot, can be defined as a macro
    
    DEBUG_PRINTF("root_getResourceSendTask: Starting to get resources and send task - Leader ID: %d, Required slots: %d", 
                leader, resourceDesc.numSlots);
        
    // 1.Based on the number of slots specified in resourceDesc, traverse root_vars.slotResource to find available slots and fill them into resource
    for (i = root_vars.slotResource.start; i < MAX_GLOBAL_SLOTS && count < resourceDesc.numSlots; i++) {
        // Check if this slot has enough available channels
        if (root_vars.slotResource.slots[i].numChannels >= channelsPerSlot) {
            // Found available slot, set basic information
            resource[count].slotOffset = i;
            resource[count].type = CELLTYPE_TX; // Default to TX type, can be modified as needed
            resource[count].owner = leader;
            
            //DEBUG_PRINTF("root_getResourceSendTask: Found available slot %d", i);
            
            // Select specified number of channels from available ones
            uint8_t channelCount = 0;
            for (j = 0; j < MAX_GLOBAL_CHANNELS && channelCount < channelsPerSlot; j++) {
                // Check if this channel is available (via bitmap)
                if (!(root_vars.slotResource.slots[i].leaderBitmap & (1 << leader)) && root_vars.slotResource.slots[i].channelBitmap & (1ULL << j)) {
                    // Add available channel to resource
                    resource[count].channelOffsets[channelCount] = j;
                    channelCount++;
                    
                    //DEBUG_PRINTF("root_getResourceSendTask: Slot %d allocated channel %d", i, j);
                    
                    // Mark this channel as used
                    root_vars.slotResource.slots[i].channelBitmap &= ~(1ULL << j);
                    root_vars.slotResource.slots[i].numChannels--;
                }
            }
            // Mark leader using this slot
            root_vars.slotResource.slots[i].leaderBitmap |= (1 << leader);
            
            // Set actual number of allocated channels
            resource[count].numChannels = channelCount;
            
            DEBUG_PRINTF("root_getResourceSendTask: Slot %d allocated %d channels", i, channelCount);
            
            // Update count
            count++;
            
            // Exit loop if enough slots have been allocated
            if (count >= resourceDesc.numSlots) {
                //DEBUG_PRINTF("root_getResourceSendTask: Allocated enough slots %d", count);
                break;
            }
        }
    }
    // If not enough slots were allocated, restore already allocated resources
    if (count < resourceDesc.numSlots) {
        DEBUG_PRINTF("root_getResourceSendTask: Error - Not enough slots, allocated %d, needed %d", 
                    count, resourceDesc.numSlots);
        //openserial_root_printf("Error: count < resourceDesc.numSlots");
        goto gg;
    }

    DEBUG_PRINTF("root_getResourceSendTask: Resource acquisition successful, preparing to assign task");
    //openserial_root_printf("getResource success");

    if(!root_assignTask(leader, task, resource, resourceDesc)){
        DEBUG_PRINTF("root_getResourceSendTask: Error - Task assignment failed");
        //openserial_root_printf("Error: root_assignTask");
        goto gg;
    }

    DEBUG_PRINTF("root_getResourceSendTask: Task assignment successful");
    //openserial_root_printf("assignTask success");
    return TRUE;

gg:
    DEBUG_PRINTF("root_getResourceSendTask: Entering error recovery process, releasing allocated resources");
    for(uint8_t k = 0; k < count; k++) {
        uint8_t slotOffset = resource[k].slotOffset;
        
        //DEBUG_PRINTF("root_getResourceSendTask: Releasing resources for slot %d", slotOffset);
        
        // Restore channel resources for this slot
        for(uint8_t m = 0; m < resource[k].numChannels; m++) {
            uint8_t channelOffset = resource[k].channelOffsets[m];
            
            //DEBUG_PRINTF("root_getResourceSendTask: Restoring channel %d for slot %d", channelOffset, slotOffset);
            
            // Restore channel bitmap
            root_vars.slotResource.slots[slotOffset].channelBitmap |= (1ULL << channelOffset);
            root_vars.slotResource.slots[slotOffset].numChannels++;
        }

        root_vars.slotResource.slots[slotOffset].leaderBitmap &= ~(1 << leader);
    }
    
    // Output error message
    DEBUG_PRINTF("root_getResourceSendTask: Resource allocation failed: Not enough slots, needed %d, only allocated %d", 
                resourceDesc.numSlots, count);
    // openserial_root_printf("Resource allocation failed: Not enough available slots, need %d, only allocated %d", 
    //                       resourceDesc.numSlots, count);

    return FALSE;
}


bool root_assignTask(uint8_t leader, task_struct* task, root_slot_resource_t *resource, resource_desc_t resourceDesc) {
    OpenQueueEntry_t* pkt;
    uint8_t i, index;
    uint16_t sizeTemp;
    
    DEBUG_PRINTF("root_assignTask: Starting to assign task - Leader ID: %d, Task ID: %d", leader, task->taskID);
    
    task->memberCount = resourceDesc.numMembers;
    task->resCount = resourceDesc.numSlots;
    // Rule 1.1: Call openqueue_getFreePacketBuffer() to get a free packet
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if (pkt == NULL) {
        // Rule 2: Call serial function to send error message
        DEBUG_PRINTF("root_assignTask: Unable to get schedule buffer");
        //openserial_root_printf("schedule buffer fail");
        return FALSE;
    }
    
    //DEBUG_PRINTF("root_assignTask: Successfully got packet buffer, preparing to fill data");
    
    sizeTemp = sizeof(task->taskID) + 
                sizeof(task->type) + 
                sizeof(task->constraint) + 
                sizeof(task->memberCount) +
                sizeof(task->resCount) + 
                sizeof(root_slot_resource_t)*resourceDesc.numSlots;
    // Rule 1.2: Call packetfunctions_reserveHeader to expand packet payload size
    packetfunctions_reserveHeader(&pkt, sizeTemp);
    
    DEBUG_PRINTF("root_assignTask: Reserved header space %d bytes", sizeTemp);
    
    // Rule 1.3: Fill packet payload
    // First fill task information
    memcpy(&pkt->payload[0], task, sizeof(task->taskID) + sizeof(task->type) + sizeof(task->constraint) + sizeof(task->memberCount) + sizeof(task->resCount));
    pkt->payload[0] = task->virID;
    memcpy(&pkt->payload[sizeTemp-sizeof(root_slot_resource_t)*resourceDesc.numSlots], resource, sizeof(root_slot_resource_t)*resourceDesc.numSlots);

    DEBUG_PRINTF("root_assignTask: Packet filling complete, virtual task ID: %d", task->virID);

    packetfunctions_reserveHeader(&pkt, 2);
    pkt->payload[0] = CENTER_FRAME_COMMAND;
    pkt->payload[1] = CENTER_CMD_TASK_REQ;

    // Rule 1.4: Configure packet destination (unicast to leader)
    memset(&pkt->l2_nextORpreviousHop, 0, sizeof(open_addr_t));
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = leader;  // Set leader ID
    
    DEBUG_PRINTF("root_assignTask: Preparing to send task request to leader %d", leader);
    
    DEBUG_PRINTF("root_assignTask: Packet payload contents:");
    for (uint8_t i = 0; i < pkt->length; i++) {
        DEBUG_PRINTF("%d: %x",i,pkt->payload[i]);
    }

    // Rule 1.5: Use sixtop_send for asynchronous sending
    if (sixtop_send(pkt) == E_FAIL) {
        // Rule 1.6: Error handling
        DEBUG_PRINTF("root_assignTask: Send failed, releasing packet buffer");
        openqueue_freePacketBuffer(pkt);
        // openserial_root_printf("schedule send fail");
        return FALSE;
    }
    
    //DEBUG_PRINTF("root_assignTask: Send successful, starting to update leader resources");
    
    // Update leader resources
    for (i = 0; i < resourceDesc.numSlots; i++) {
        // Convert root_slot_resource_t to slot_resource_t and store
        slot_resource_t* slot = task_findAvailSlots(root_vars.leaders[leader].resource.slots, MAX_SLOT_RESOURCES);
        if(!slot){
            DEBUG_PRINTF("root_assignTask: Leader %d does not have enough slots", leader);
            // openserial_root_printf("not enough slots in leader %d",leader);
            goto gg;
        }
        task_rslotToSlot(slot,&resource[i],task);
        task->resource[i] = slot;
        
        // DEBUG_PRINTF("root_assignTask: resourse added, [slot %d, channel count %d]", 
        //             resource[i].slotOffset, resource[i].numChannels);
    }
    
    task->resCount = resourceDesc.numSlots;
    
    DEBUG_PRINTF("root_assignTask: slot count: %d", task->resCount);
    
    // Update leader's slot count
    root_vars.leaders[leader].resource.numSlots += resourceDesc.numSlots;
    
    // Update task status
    task->leaderID = leader;
    task->active = TRUE;
    task->progress = 0;
    
    DEBUG_PRINTF("root_assignTask: Task status updated - Leader ID: %d, Active status: %d", 
                task->leaderID, task->active);
    
    // Update leader task count
    root_tasks_vars.leaders[leader].taskCount++;
    index = task_findFirstInactive(root_tasks_vars.leaders[leader].tasks,MAX_TASKS_PER_LEADER);
    root_tasks_vars.leaders[leader].tasks[index] = task;
    
    DEBUG_PRINTF("root_assignTask: Updated leader task count %d, task index %d", 
                root_tasks_vars.leaders[leader].taskCount, index);

    return TRUE;
gg:
    //DEBUG_PRINTF("root_assignTask: Entering error recovery process");
    for(uint8_t k = 0; k < i; k++){
        task->resource[k]->type = CELLTYPE_OFF;
        //DEBUG_PRINTF("root_assignTask: Releasing slot resource %d", k);
    }
    return FALSE;
}


//传入的参数task在调用此函数前配置，取全局变量task。
void root_handleTask(task_struct* task) {
    task_type* type;
    task_constraint* constraint;
    uint8_t leader;
    resource_desc_t resourceDesc;
    root_slot_resource_t resource[MAX_SLOTS_PER_TASK];
    
    DEBUG_PRINTF("root_handleTask: Starting to process task ID %d", task->taskID);
    
    // 1.Get task type and performance requirements
    type = &task->type;
    constraint = &task->constraint;
    
    DEBUG_PRINTF("root_handleTask: Task type - Attribute: %d, Class: %d", type->attr, type->class);
    
    // 2.Select leader node to accept this task based on task type
    leader = root_taskChooseLeader(type->class, task->taskID);
    if (leader == 0xFF) {
        // No available leader, task needs to be queued
        DEBUG_PRINTF("root_handleTask: No available leader, task needs to be queued");
        // openserial_root_printf("no leader available");
        return;
    }
    
    DEBUG_PRINTF("root_handleTask: Selected leader ID: %d", leader);
    
    // 3.Calculate required resources
    resourceDesc = root_calcTaskResource(leader, type->attr, constraint);
    
    DEBUG_PRINTF("root_handleTask: Calculated resource requirements - Slots: %d, Members: %d", 
                resourceDesc.numSlots, resourceDesc.numMembers);
    
    // 4.Root node checks if global remaining resources can meet requirements
    if (root_vars.slotResource.numSlots >= resourceDesc.numSlots) {
        // 4.1 If sufficient, prepare to allocate task and resources to leader
        //DEBUG_PRINTF("root_handleTask: Global resources meet requirements, starting resource allocation");
        
        if(root_getResourceSendTask(leader, task, resourceDesc, resource)){
            // Update global resources
            root_tasks_vars.activeTaskCount++;
            DEBUG_PRINTF("root_handleTask: Resource allocation successful, active task count increased to %d", 
                        root_tasks_vars.activeTaskCount);
        }else{
            DEBUG_PRINTF("root_handleTask: Resource allocation failed");
            // openserial_root_printf("wrong: root_getResourceSendTask");
        }
    } else {
        // 4.2 Insufficient resources, queue for waiting
        DEBUG_PRINTF("root_handleTask: Insufficient global resources, current %d, needed %d", 
                    root_vars.slotResource.numSlots, resourceDesc.numSlots);
        
        if (root_tasks_vars.leaders[leader].queuedTaskCount < MAX_QUEUED_TASKS) {
            // 4.2.1 Queue successful
            if(!task_queue_enqueue(&queue, task)){
                DEBUG_PRINTF("root_handleTask: Task enqueue failed");
                return;
                // openserial_root_printf("queue fail");
            }
            root_tasks_vars.leaders[leader].queuedTaskCount++;
            root_tasks_vars.queuedTaskCount++;
            DEBUG_PRINTF("root_handleTask: Task successfully queued, leader %d queued tasks: %d, global queued tasks: %d", 
                        leader, 
                        root_tasks_vars.leaders[leader].queuedTaskCount, 
                        root_tasks_vars.queuedTaskCount);
            // openserial_root_printf("task queued");
        } else {
            // 4.2.2 Queue failed
            DEBUG_PRINTF("root_handleTask: Leader %d queue is full, cannot queue", leader);
            // openserial_root_printf("queue full");
        }
    }
}

void root_handleTaskResponse(OpenQueueEntry_t* msg) {
    uint8_t taskID;
    uint8_t response;
    
    DEBUG_PRINTF("root_handleTaskResponse: Starting to process task response");
    
    // 1.从消息中提取任务ID和响应结果
    taskID = msg->payload[0];
    response = msg->payload[1];
    
    DEBUG_PRINTF("root_handleTaskResponse: Task ID: %d, Response: %d", taskID, response);

    // 2.检查任务ID是否有效
    if (taskID >= MAX_TASKS_PER_LEADER * MAX_LEADERS) {
        DEBUG_PRINTF("root_handleTaskResponse: Invalid task ID %d", taskID);
        // openserial_root_printf("Invalid task ID %d", taskID);
        return;
    }
    
    // 3.处理任务响应
    if (response == 1) {
        // 3.1 任务被接受
        DEBUG_PRINTF("root_handleTaskResponse: Task %d accepted by leader", taskID);
        // openserial_root_printf("Task %d accepted", taskID);
        
        // 更新任务状态为已接受
        tasks[taskID].active = TRUE;
    } else {
        // 3.2 任务被拒绝
        DEBUG_PRINTF("root_handleTaskResponse: Task %d rejected by leader", taskID);
        // openserial_root_printf("Task %d rejected", taskID);
        
        // 释放已分配的资源
        for(uint8_t i = 0; i < MAX_SLOTS_PER_TASK; i++) {
            if (tasks[taskID].resource[i] != NULL) {
                uint8_t slotOffset = tasks[taskID].resource[i]->slotOffset;
                for(uint8_t j = 0; j < tasks[taskID].resource[i]->numChannels; j++) {
                    uint8_t channelOffset = tasks[taskID].resource[i]->channels[j].channelOffset;
                    root_vars.slotResource.slots[slotOffset].channelBitmap |= (1ULL << channelOffset);
                    root_vars.slotResource.slots[slotOffset].numChannels++;
                }
                root_vars.slotResource.slots[slotOffset].leaderBitmap &= ~(1 << tasks[taskID].leaderID);
            }
        }
        
        // 更新全局资源计数
        root_vars.slotResource.numSlots += tasks[taskID].resCount;
        
        // 释放任务容器
        task_freeTaskContainer(&tasks[taskID]);
        root_tasks_vars.activeTaskCount--;
        
        DEBUG_PRINTF("root_handleTaskResponse: Resources released for rejected task %d", taskID);
    }
}

/**
 * 释放任务占用的资源
 * @param taskID 要释放资源的任务ID
 */
static void root_releaseTaskResources(uint8_t taskID) {
    DEBUG_PRINTF("root_releaseTaskResources: Starting to release resources for task %d", taskID);
    
    // 释放任务占用的资源
    for(uint8_t i = 0; i < MAX_SLOTS_PER_TASK; i++) {
        if (tasks[taskID].resource[i] != NULL) {
            // 恢复时隙资源
            uint8_t slotOffset = tasks[taskID].resource[i]->slotOffset;
            DEBUG_PRINTF("root_releaseTaskResources: Releasing slot %d and its %d channels", 
                       slotOffset, tasks[taskID].resource[i]->numChannels);
            
            for(uint8_t j = 0; j < tasks[taskID].resource[i]->numChannels; j++) {
                uint8_t channelOffset = tasks[taskID].resource[i]->channels[j].channelOffset;
                root_vars.slotResource.slots[slotOffset].channelBitmap |= (1ULL << channelOffset);
                root_vars.slotResource.slots[slotOffset].numChannels++;
            }
            
            // 清除组长位图
            root_vars.slotResource.slots[slotOffset].leaderBitmap &= ~(1 << tasks[taskID].leaderID);
            
            task_freeTaskContainer(&tasks[taskID]);
            tasks[taskID].resource[i] = NULL;
        }
    }
    
    // 更新活动任务计数
    if (root_tasks_vars.activeTaskCount > 0) {
        root_tasks_vars.activeTaskCount--;
        DEBUG_PRINTF("root_releaseTaskResources: Active task count decreased to %d", root_tasks_vars.activeTaskCount);
    }
    
    DEBUG_PRINTF("root_releaseTaskResources: Resources released for task %d", taskID);
}

void root_handleTaskProgress(OpenQueueEntry_t* msg) {
    uint8_t taskID;
    uint8_t progress;
    
    DEBUG_PRINTF("root_handleTaskProgress: Starting to process task progress update");
    
    // 1.Extract task ID and progress from message
    taskID = msg->payload[0];
    progress = msg->payload[1];
    
    DEBUG_PRINTF("root_handleTaskProgress: Task ID: %d, Progress: %d%%", taskID, progress);

    // 3.Update task status
    if (taskID < MAX_TASKS_PER_LEADER * MAX_LEADERS) {
        
        tasks[taskID].progress = progress;
        
        DEBUG_PRINTF("root_handleTaskProgress: Updated task %d progress to %d%%", taskID, progress);
        
        if (progress < 100) {
            // Task not completed, only update progress
            DEBUG_PRINTF("root_handleTaskProgress: Task %d not completed, only updating progress", taskID);
            // openserial_root_printf("Task %d progress updated to %d%%", taskID, progress);
        } else {
            // Task completed, release resources
            DEBUG_PRINTF("root_handleTaskProgress: Task %d completed, starting to release resources", taskID);
            // openserial_root_printf("Task completion notification: Task ID=%d, Progress=%d%%", taskID, progress);
            
            // 调用资源释放函数
            root_releaseTaskResources(taskID);
            
            // 6.Check if there are queued tasks that can be executed
            if (!task_queue_isEmpty(&queue)) {
                task_struct* nextTask;
                DEBUG_PRINTF("root_handleTaskProgress: Queue not empty, preparing to process next task");
                if (task_queue_dequeue(&queue,&nextTask)) {
                    DEBUG_PRINTF("root_handleTaskProgress: Dequeued task ID=%d from queue", nextTask->taskID);
                    // openserial_root_printf("[DEBUG] Dequeuing next task ID=%d from queue", nextTask->taskID);
                    root_handleTask(nextTask);
                }
            } else {
                DEBUG_PRINTF("root_handleTaskProgress: No queued tasks");
            }
        }
    } else {
        DEBUG_PRINTF("root_handleTaskProgress: Error - Invalid task ID %d", taskID);
        // openserial_root_printf("Error: Invalid task ID");
    }
}


/**
 * leader开头的系列函数实现
 */
void leader_initTaskHandler() {
    uint8_t i;
    
    DEBUG_PRINTF("leader_initTaskHandler: Starting to initialize leader task management system");
    
    // 初始化任务存放实例
    for(i = 0; i < MAX_TASKS_PER_LEADER * MAX_LEADERS; i++){
        tasks[i].taskID = 0;
        tasks[i].active = FALSE;
        tasks[i].progress = 0;
        tasks[i].leaderID = 0;
        tasks[i].compatibleMask = 0;
        tasks[i].type.attr = 0;
        tasks[i].type.class = 0;
        
        for(uint8_t j = 0; j < MAX_SLOTS_PER_TASK; j++) {
            tasks[i].resource[j] = NULL;
        }
    }    
    
    DEBUG_PRINTF("leader_initTaskHandler: Task storage instance initialization complete");
    
    // 初始化组长的正在执行的任务链表
    for (i = 0; i < MAX_TASKS_PER_LEADER; i++) {
        leader_tasks_vars.activeTasks[i].task = NULL;  // 初始化为空
        leader_tasks_vars.activeTasks[i].memberCount = 0;
        leader_tasks_vars.activeTasks[i].ebEnabled = FALSE;
        leader_tasks_vars.activeTasks[i].state = FREE;
        
        memset(leader_tasks_vars.activeTasks[i].members, 0, MAX_MEMBERS_PER_TASK);
    }
    
    DEBUG_PRINTF("leader_initTaskHandler: Task list initialization complete");
    
    leader_tasks_vars.activeTaskCount = 0;
    
    DEBUG_PRINTF("leader_initTaskHandler: Leader task management system initialization complete");

    task_queue_init(&queue);
}


uint8_t leader_taskChooseMember(member_monitor_t *membersChosen[], task_struct *task) {
    uint8_t count = 0;
    
    DEBUG_PRINTF("leader_taskChooseMember: Starting to choose members for task, task ID: %d", task->taskID);
    
    // 遍历所有组员
    for(uint8_t i = 0; i < leader_vars.numMembers && count < task->memberCount; i++) {
        // 检查组员是否空闲（此处简单处理，找到未执行任务的member即可。可优化为不与当前任务冲突的member）
        if(leader_vars.members[i].state == NODE_STATE_ONLINE && 
           !leader_vars.members[i].isTaskActive) {
            // 将空闲组员添加到选择列表
            membersChosen[count] = &leader_vars.members[i];
            count++;
            //DEBUG_PRINTF("leader_taskChooseMember: Selected member ID: %d, currently selected %d", leader_vars.members[i].id, count);
        } else {
            //DEBUG_PRINTF("leader_taskChooseMember: Member ID: %d not selectable, state: %d, task active: %d", leader_vars.members[i].id, leader_vars.members[i].state, leader_vars.members[i].isTaskActive);
        }
    }
    
    DEBUG_PRINTF("leader_taskChooseMember: Selection complete, found %d members, task requires %d", count, task->memberCount);
    
    // 返回找到的空闲组员数量
    return count;
}

//将task->resCount个时隙资源task->resource[i]平均分给memberFound个member，每个member的实例member_monitor_t
bool leader_slotAllocation(member_monitor_t *membersChosen[], uint8_t memberFound, task_struct *task) {
    uint8_t slotsPerMember;
    uint8_t extraSlots;
    uint8_t slotIndex = 0;
    uint8_t tempTaskIndex[MAX_TASKS_PER_MEMBER];
    
    DEBUG_PRINTF("leader_slotAllocation: Starting slot allocation for task %d with %d members", task->taskID, memberFound);
    
    // Calculate slots per member
    if (memberFound > 0) {
        slotsPerMember = task->resCount / memberFound;
        // 计算剩余的额外时隙数
        extraSlots = task->resCount % memberFound;
        DEBUG_PRINTF("leader_slotAllocation: %d slots per member, %d extra slots", slotsPerMember, extraSlots);
    } else {
        DEBUG_PRINTF("leader_slotAllocation: No available members, allocation failed");
        return FALSE;
    }
    
    // Allocate slots to each member
    for (uint8_t i = 0; i < memberFound; i++) {
        uint8_t allocatedSlots = slotsPerMember;
        
        // 分配额外时隙（按顺序分配）
        if (extraSlots > 0) {
            allocatedSlots++;
            extraSlots--;
        }
        
        DEBUG_PRINTF("leader_slotAllocation: Allocating %d slots to member %d", allocatedSlots, membersChosen[i]->id);
        
        for (uint8_t j = 0, taskIndex = 0; j < allocatedSlots && slotIndex < task->resCount; j++) {
            // 将时隙资源分配给该成员
            if (task->resource[slotIndex] != NULL) {
                task->resource[slotIndex]->owner = membersChosen[i]->id;
                task->resource[slotIndex]->taskID = task->taskID;
                task->resource[slotIndex]->channelOffsetIndex = 0;
                DEBUG_PRINTF("leader_slotAllocation: Slot %d assigned to member %d", slotIndex, membersChosen[i]->id);
            } else {
                DEBUG_PRINTF("leader_slotAllocation: WARNING - Slot resource %d is NULL", slotIndex);
            }

            slotIndex++;
        }
        membersChosen[i]->isTaskActive = TRUE;
    }
    

    // 将task的每个resource转换为用于传输给member的center_slot_t。
    // 再将任务（只包含taskID、type、constraint）和资源一起发送给member。

    // 将时隙资源转换为center_slot_t并发送给成员
    for (uint8_t i = 0; i < memberFound; i++) {
        OpenQueueEntry_t* pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
        if (pkt == NULL) {
            DEBUG_PRINTF("leader_slotAllocation: ERROR - Failed to get packet buffer");
            goto gg;
        }
        
        // 计算该成员分配的时隙数量
        uint8_t memberSlotCount = slotsPerMember + (i < extraSlots ? 1 : 0);
        uint8_t startSlotIndex = i * slotsPerMember + (i < extraSlots ? i : extraSlots);
        
        uint8_t taskInfoSize = sizeof(task->taskID) + sizeof(task->type) + sizeof(task->constraint);
        packetfunctions_reserveHeader(&pkt, taskInfoSize + memberSlotCount * sizeof(center_slot_t));
        
        // 填充任务基本信息
        uint8_t* ptr = pkt->payload;
        
        memcpy(ptr, &task->virID, sizeof(task->taskID));
        ptr += sizeof(task->taskID);
        memcpy(ptr, &task->type, sizeof(task->type));
        ptr += sizeof(task->type);
        memcpy(ptr, &task->constraint, sizeof(task->constraint));
        ptr += sizeof(task->constraint);
        
        // 填充该成员的时隙资源（转换为center_slot_t格式）
        for (uint8_t j = 0; j < memberSlotCount; j++) {
            uint8_t currentSlotIndex = startSlotIndex + j;
            if (currentSlotIndex < task->resCount && task->resource[currentSlotIndex] != NULL) {
                center_slot_t cslot;
                task_slotToCslot(task->resource[currentSlotIndex], &cslot);
                memcpy(ptr, &cslot, sizeof(center_slot_t));
                ptr += sizeof(center_slot_t);
            }
        }
        packetfunctions_reserveHeader(&pkt, 2);
        pkt->payload[0] = CENTER_FRAME_COMMAND;
        pkt->payload[1] = CENTER_CMD_TASK_REQ;

        memset(&pkt->l2_nextORpreviousHop, 0, sizeof(open_addr_t));
        pkt->l2_nextORpreviousHop.type = ADDR_64B;
        pkt->l2_nextORpreviousHop.addr_64b[7] = membersChosen[i]->id;
        
        if (sixtop_send(pkt) != E_SUCCESS) {
            DEBUG_PRINTF("leader_slotAllocation: ERROR - Failed to send task allocation to member %d", membersChosen[i]->id);
            openqueue_freePacketBuffer(pkt);
            goto gg;
        }
        
        DEBUG_PRINTF("leader_slotAllocation: Successfully sent %d slots for task %d to member %d", 
                    memberSlotCount, task->taskID, membersChosen[i]->id);
    }

    leader_vars.freeMembers -= memberFound;
    DEBUG_PRINTF("leader_slotAllocation: Slot allocation completed successfully");
    return TRUE;
    
gg:
    DEBUG_PRINTF("leader_slotAllocation: Slot allocation failed");
    return FALSE;
    // for (uint8_t i = 0; i < memberFound; i++) {
    //     membersChosen[i]->tasks[tempTaskIndex[i]] = NULL;
    // }
}

bool leader_assignTaskPrepare(task_struct *task){
    uint8_t memberFound, index;
    member_monitor_t *membersChosen[MAX_MEMBERS_PER_TASK];
    OpenQueueEntry_t* reply;

    DEBUG_PRINTF("leader_assignTaskPrepare: Start preparing task assignment, taskID: %d", task->taskID);
    
    memberFound = leader_taskChooseMember(membersChosen, task);
    index = task->indexTbl;
    
    DEBUG_PRINTF("leader_assignTaskPrepare: Selected %d members, task requires %d members", 
               memberFound, task->memberCount);
    
    // 4.Check if human resources meet requirements
    if (memberFound >= task->memberCount) {
        // Sufficient human resources
        DEBUG_PRINTF("leader_assignTaskPrepare: Sufficient human resources, starting slot allocation");
        
        if(!leader_slotAllocation(membersChosen,memberFound,task)){
            openserial_leader_printf("leader_assignTaskPrepare: Slot allocation failed");
            goto gg;
        }

        reply = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
        if (reply == NULL) {
            DEBUG_PRINTF("leader_handleTask: Cannot get buffer");
            openserial_leader_printf("buffer fail");
            return;
        }    

        packetfunctions_reserveHeader(&reply, 2);
        reply->payload[0] = task->taskID;
        reply->payload[1] = 1;  // 1 means accept

        packetfunctions_reserveHeader(&reply, 2);
        reply->payload[0] = CENTER_FRAME_COMMAND;
        reply->payload[1] = CENTER_CMD_TASK_RESP;
        
        DEBUG_PRINTF("leader_assignTaskPrepare: Sending task accept message (1)");
        
        memset(&reply->l2_nextORpreviousHop, 0, sizeof(open_addr_t));
        reply->l2_nextORpreviousHop.type = ADDR_64B;
        reply->l2_nextORpreviousHop.addr_64b[7] = 0x11;
        
        if (sixtop_send(reply) == E_FAIL) {
            DEBUG_PRINTF("leader_assignTaskPrepare: Send failed");
            openqueue_freePacketBuffer(reply);
            goto gg;
        }

        leader_tasks_vars.activeTasks[index].state = WORKING;
        DEBUG_PRINTF("leader_assignTaskPrepare: Task state set to WORKING");
    } else {
        // 5.Insufficient human resources, enable EB recruitment
        DEBUG_PRINTF("leader_assignTaskPrepare: Insufficient human resources, need to enable EB recruitment");

        if(task_queue_enqueue(&queue, task)){
            DEBUG_PRINTF("leader_assignTaskPrepare: Task enqueued waiting for recruitment");
        }else{
            DEBUG_PRINTF("leader_assignTaskPrepare: Task enqueue failed");
            goto gg;
        }

        //Consider combining EB startup into a function
        leader_tasks_vars.activeTasks[index].ebEnabled = TRUE;
        leader_vars.ebEnabled = TRUE;
        leader_tasks_vars.activeTasks[index].state = RECRUITING; 
        
        DEBUG_PRINTF("leader_assignTaskPrepare: EB enabled, state set to RECRUITING");
        
        // 5.1 Mark task as waiting for recruitment
        // openserial_leader_printf("handletask: leader set ebEnable TRUE");
        
        // // Send wait message
        // reply = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
        // if (reply == NULL) {
        //     DEBUG_PRINTF("leader_assignTaskPrepare: Cannot get packet buffer");
        //     openserial_leader_printf("handletask: reply buffer fail");
        //     goto dequeue_gg;
        // }
        
        // packetfunctions_reserveHeader(&reply, 1);
        // reply->payload[0] = 2; // 2 means wait for recruitment
        
        // DEBUG_PRINTF("leader_assignTaskPrepare: Sending wait for recruitment message (2)");
        
        // memset(&reply->l2_nextORpreviousHop, 0, sizeof(open_addr_t));
        // reply->l2_nextORpreviousHop.type = ADDR_64B;
        // reply->l2_nextORpreviousHop.addr_64b[7] = 0x11;
        
        // if (sixtop_send(reply) == E_FAIL) {
        //     DEBUG_PRINTF("leader_assignTaskPrepare: Send failed");
        //     openqueue_freePacketBuffer(reply);
        //     openserial_leader_printf("handletask: reply send fail");
        //     goto dequeue_gg;
        // } else {
        //     DEBUG_PRINTF("leader_assignTaskPrepare: Wait for recruitment message sent successfully");
        // }
    }
    
    DEBUG_PRINTF("leader_assignTaskPrepare: Task preparation completed");
    return TRUE;

dequeue_gg:
    task_queue_dequeue(&queue, &task);
gg:
    task_freeTaskContainer(task);
    return FALSE;
}



void leader_handleTask(OpenQueueEntry_t* msg) {
    task_struct *task;
    root_slot_resource_t resource[MAX_SLOTS_PER_TASK];
    uint8_t i;
    OpenQueueEntry_t* reply;

    DEBUG_PRINTF("leader_handleTask: Start processing task request from root node");
    // 1.Get task, human resources, slot resources from msg
    // 1.1 Parse task info from message
    uint8_t sizeTemp = 0;
    task = task_findFreeTaskContainer(tasks, MAX_TASKS_PER_LEADER * MAX_LEADERS);
    if(!task){
        DEBUG_PRINTF("leader_handleTask: No available task container");
        openserial_leader_printf("task full");
        return;
    }
    openserial_printData(msg->payload, msg->length);
    // Calculate task struct size
    sizeTemp = sizeof(task->taskID) + 
               sizeof(task->type) + 
               sizeof(task->constraint) + 
               sizeof(task->memberCount) +
               sizeof(task->resCount);
    
    DEBUG_PRINTF("leader_handleTask: Task struct size: %d", sizeTemp);

    //Copy task info from payload
    memcpy(task, &msg->payload[0], sizeTemp);
    // 1.2 Copy resource info from payload
    memcpy(resource, &msg->payload[sizeTemp], sizeof(root_slot_resource_t) * task->resCount);

    DEBUG_PRINTF("leader_handleTask: Parsed task info - ID: %d, attr: %d, class: %d, Resource count: %d, Member count: %d", 
                task->taskID, task->type.attr, task->type.class, task->resCount, task->memberCount);
    

    //openserial_leader_printf("Received task ID:%d, Type:%d, Slot resources:%d, Member resources:%d", task->taskID, task->type, task->resCount, task->memberCount);
    // 2.Check if leader resources meet requirements
    if (leader_tasks_vars.activeTaskCount >= MAX_TASKS_PER_LEADER) {
        // Task count full, reject
        DEBUG_PRINTF("leader_handleTask: Task count full, preparing to reject task");
        
        reply = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
        if (reply == NULL) {
            DEBUG_PRINTF("leader_handleTask: Cannot get buffer");
            openserial_leader_printf("buffer fail");
            return;
        }
        openserial_leader_printf("leader %d: buffer fail", center_vars.myId);

        // Fill reject message
        packetfunctions_reserveHeader(&reply, 2);
        reply->payload[0] = task->taskID;
        reply->payload[1] = 0; // 0 means reject


        packetfunctions_reserveHeader(&reply, 2);
        reply->payload[0] = CENTER_FRAME_COMMAND;
        reply->payload[1] = CENTER_CMD_TASK_RESP;
        
        DEBUG_PRINTF("leader_handleTask: Sending reject message (0)");
        
        // Unicast send
        memset(&reply->l2_nextORpreviousHop, 0, sizeof(open_addr_t));
        reply->l2_nextORpreviousHop.type = ADDR_64B;
        reply->l2_nextORpreviousHop.addr_64b[7] = 0x11;
        
        if (sixtop_send(reply) == E_FAIL) {
            DEBUG_PRINTF("leader_handleTask: Send failed");
            openqueue_freePacketBuffer(reply);
            openserial_leader_printf("send fail");
        }
        
        return;
    }

    // Update leader resources
    DEBUG_PRINTF("leader_handleTask: Start updating leader resources");
    
    for (i = 0; i < task->resCount; i++) {
        // Convert root_slot_resource_t to slot_resource_t and store
        slot_resource_t* slot = task_findAvailSlots(leader_vars.resourceManager.slots, MAX_SLOT_RESOURCES);
        if(!slot){
            DEBUG_PRINTF("leader_handleTask: Insufficient leader resources");
        }
        task_rslotToSlot(slot,&resource[i],&task);
        task->resource[i] = slot;
        
        //DEBUG_PRINTF("leader_handleTask: Resource %d update completed", i);
    }
    
    // 3.Record task locally
    i = task_getFreeTaskList();
    if(i == MAX_TASKS_PER_LEADER) {
        DEBUG_PRINTF("leader_handleTask: No available task list");
        openserial_leader_printf("no free task list");
        return;
    }
    leader_tasks_vars.activeTaskCount++;
    leader_tasks_vars.activeTasks[i].state = WORKING;
    leader_tasks_vars.activeTasks[i].task = task;
    task->indexTbl = i;
    
    DEBUG_PRINTF("leader_handleTask: Task recorded, indexTbl: %d, active task count: %d", 
                i, leader_tasks_vars.activeTaskCount);

    leader_assignTaskPrepare(task);
    
    DEBUG_PRINTF("leader_handleTask: Task assignment preparation completed");
}



void leader_adjustTaskResource(task_struct *task, uint8_t memberID, uint8_t effi, uint8_t util) {
    
    // 这里用于组长调整指定组员的时隙资源
    if (effi < 50 && util == 100) { // Efficiency below 50% and utilization at 100%, need to increase slots
        // Should call leader_adjustTaskResource function, not implemented yet.
        DEBUG_PRINTF("Need to increase resources to member %d", memberID);
        //openserial_leader_printf("should increase resource");
    }
    if (effi == 100 && util < 80) {
        DEBUG_PRINTF("Need to reduce resources to member %d", memberID);
        //openserial_leader_printf("should reduce resource");
    }    
}

void leader_handleTaskProgress(OpenQueueEntry_t* msg) {
    task_struct *task;
    uint8_t taskID,virID,memberID;
    uint8_t progress,efficiency,utilization;
    OpenQueueEntry_t* report;
    
    DEBUG_PRINTF("leader_handleTaskProgress: Start processing member's task progress update");
    
    // 1.Get task ID, progress and efficiency metrics from msg
    virID = msg->payload[0];
    progress = msg->payload[1];
    efficiency = msg->payload[2];
    utilization = msg->payload[3];
    memberID = msg->l2_nextORpreviousHop.addr_64b[7];
    
    DEBUG_PRINTF("leader_handleTaskProgress: Received progress data - Virtual ID: %d, Progress: %d%%, Efficiency: %d%%, Utilization: %d%%", 
                virID, progress, efficiency, utilization);

    // Check if task ID is valid
    if (virID >= MAX_TASKS_PER_LEADER * MAX_LEADERS) {
        DEBUG_PRINTF("leader_handleTaskProgress: Invalid task ID");
        openserial_leader_printf("invalid task");
        return;
    }
    
    task = &tasks[virID];
    taskID = task->taskID;
    // 2.
    task->progress = progress;
    //leader_tasks_vars.activeTasks[task->indexTbl].task->progress = progress;
    
    DEBUG_PRINTF("leader_handleTaskProgress: Updated task %d progress to %d%%", taskID, progress);
    
    // 3.Simple check if task is completed
    if (progress >= 100) {
        // 4.Task completed, report to root
        DEBUG_PRINTF("leader_handleTaskProgress: Task %d completed, starting cleanup", taskID);
        leader_taskCompleted(task);
    } else {
        // 5.Task not completed, check if slot resources need adjustment
        leader_adjustTaskResource(task, memberID, efficiency, utilization);
    }

    DEBUG_PRINTF("leader_handleTaskProgress: Preparing to report progress to root");
    
    report = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if (report == NULL) {
        DEBUG_PRINTF("leader_handleTaskProgress: Cannot get packet buffer");
        openserial_leader_printf("buffer fail");
        return;
    }
    packetfunctions_reserveHeader(&report, 2);
    report->payload[0] = taskID;
    report->payload[1] = progress;

    packetfunctions_reserveHeader(&report, 2);
    report->payload[0] = CENTER_FRAME_COMMAND;
    report->payload[1] = CENTER_CMD_TASK_PROGRESS;
    
    DEBUG_PRINTF("leader_handleTaskProgress: Configured to send to root - Task ID: %d, Progress: %d%%", 
                taskID, progress);
    
    memset(&report->l2_nextORpreviousHop, 0, sizeof(open_addr_t));
    report->l2_nextORpreviousHop.type = ADDR_64B;
    report->l2_nextORpreviousHop.addr_64b[7] = 0x11; // Assume root ID is 0
    
    if (sixtop_send(report) == E_FAIL) {
        DEBUG_PRINTF("leader_handleTaskProgress: Send failed");
        openqueue_freePacketBuffer(report);
        openserial_leader_printf("send fail");
    } else {
        DEBUG_PRINTF("leader_handleTaskProgress: Progress report sent successfully");
    }
}

//Cleanup work after leader completes task
void leader_taskCompleted(task_struct *task){
    uint8_t taskID = task->taskID;
    
    DEBUG_PRINTF("leader_taskCompleted: Starting cleanup for completed task ID=%d", taskID);
    
    openserial_leader_printf("[DEBUG] Leader: Starting cleanup for completed task ID=%d", taskID);
    
    // Release slot resources used by task
    for(uint8_t i = 0; i < task->resCount; i++) {
        if(task->resource[i] != NULL) {
            DEBUG_PRINTF("leader_taskCompleted: Releasing slot %d, channel %d", 
                        task->resource[i]->slotOffset, 
                        task->resource[i]->channels[task->resource[i]->channelOffsetIndex].channelOffset);
            
            // openserial_leader_printf("[DEBUG] Leader: Releasing slot %d, channel %d", 
            //                        task->resource[i]->slotOffset, 
            //                        task->resource[i]->channels[task->resource[i]->channelOffsetIndex].channelOffset);

            // Mark slot as unused
            task->resource[i]->type = CELLTYPE_OFF;
            // Cleanup registration
            // schedule_removeActiveSlot(task->resource[i]->slotOffset, 
            // task->resource[i]->channels[task->resource[i]->channelOffsetIndex].channelOffset);
            task->resource[i] = NULL;
        }
    }
    
    // Release task resources
    leader_tasks_vars.activeTasks[task->indexTbl].state = FREE;
    leader_tasks_vars.activeTasks[task->indexTbl].ebEnabled = FALSE;
    leader_tasks_vars.activeTaskCount--;
    
    DEBUG_PRINTF("leader_taskCompleted: Task status updated - Index: %d, Active task count: %d", 
                task->indexTbl, leader_tasks_vars.activeTaskCount);
    
    task_freeTaskContainer(task);
    
    DEBUG_PRINTF("leader_taskCompleted: Task %d fully released", taskID);
    
    openserial_leader_printf("Task %d completed and released", taskID);
    openserial_leader_printf("[DEBUG] Leader: Task ID=%d fully released. Active tasks remaining: %d", 
                           taskID, leader_tasks_vars.activeTaskCount);
}




/**
 * Functions starting with member
 */
void member_initTaskHandler() {
    uint8_t i;
    
    DEBUG_PRINTF("member_initTaskHandler: Starting to initialize member task management system");
    
    // Initialize member's active task list
    for (i = 0; i < MAX_TASKS_PER_MEMBER; i++) {
        member_tasks_vars.activeTasks[i].task = NULL; // Initialize as empty
        member_tasks_vars.activeTasks[i].state = FREE;
        member_tasks_vars.activeTasks[i].slotCount = 0;
        memset(member_tasks_vars.activeTasks[i].slotResources, 0, sizeof(center_slot_t) * MAX_SLOTS_PER_TASK);
    }
    
    DEBUG_PRINTF("member_initTaskHandler: Task list initialization completed");
    
    member_tasks_vars.activeTaskCount = 0;
    task_queue_init(&queue);
    
    DEBUG_PRINTF("member_initTaskHandler: Member task management system initialization completed");
}

void member_handleTask(OpenQueueEntry_t* msg) {
    uint8_t* ptr = msg->payload;
    uint8_t taskID, i;
    task_type type;
    task_constraint constraint;
    OpenQueueEntry_t* reply;
    bool success = TRUE;
    task_struct* task;
    
    DEBUG_PRINTF("member_handleTask: Start processing task request from leader");
    
    // 1. Parse task info from message
    // Parse task ID (upper layer virtual ID)
    memcpy(&taskID, ptr, sizeof(taskID));
    ptr += sizeof(taskID);
    
    DEBUG_PRINTF("member_handleTask: Received new task request (ID=%d)", taskID);
        
    // Parse task type
    memcpy(&type, ptr, sizeof(task_type));
    ptr += sizeof(task_type);
    
    DEBUG_PRINTF("member_handleTask: Task type - Attribute: %d, Class: %d", type.attr, type.class);
    
    // Parse task constraint
    memcpy(&constraint, ptr, sizeof(task_constraint));
    ptr += sizeof(task_constraint);
    
    DEBUG_PRINTF("member_handleTask: Task constraint parsing complete");
    
    // 2. 检查是否有足够空间注册新任务
    if (member_tasks_vars.activeTaskCount >= MAX_TASKS_PER_MEMBER) {
        // 时隙注册失败，没有足够空间
        success = FALSE;
        openserial_member_printf("Task registration failed: Maximum task count reached");
        return;    
    }
    i = task_getFreeTaskList();
    if(i == MAX_TASKS_PER_MEMBER) {
        openserial_member_printf("no free task list");
        return;
    }
    member_tasks_vars.activeTaskCount++;
    member_tasks_vars.activeTasks[i].state = WORKING;

    // 获取空闲任务容器
    task = task_findFreeTaskContainer(tasks, MAX_TASKS_PER_LEADER * MAX_LEADERS);
    if (task == NULL) {
        openserial_member_printf("no empty task container");
        success = FALSE;
        goto gg;
    } 

    // 初始化任务结构体
    task->taskID = taskID;
    task->type = type;
    task->constraint = constraint;
    task->leaderID = msg->l2_nextORpreviousHop.addr_64b[7]; // 从发送者地址获取leaderID
    task->progress = 0;
    task->active = TRUE;
    task->indexTbl= i;
    member_tasks_vars.activeTasks[i].task = task;
    
    
    // 计算消息中包含的时隙数量
    uint8_t slotCount = (msg->length - (sizeof(taskID) + sizeof(task_type) + sizeof(task_constraint))) / sizeof(center_slot_t);
    member_tasks_vars.activeTasks[i].slotCount = slotCount;
    openserial_member_printf("Member: Registering task ID=%d with %d slots from leader ID=%d", 
                            taskID, slotCount, task->leaderID);
    
    // 注册时隙资源
    for (uint8_t j = 0; j < slotCount && j < MAX_SLOTS_PER_TASK; j++) {
        // 转换为本地时隙资源格式并注册
        center_slot_t *cslot = &member_tasks_vars.activeTasks[i].slotResources[j];
        memcpy(cslot, ptr, sizeof(center_slot_t));
        ptr += sizeof(center_slot_t);
        
        // 打印时隙和信道偏移信息用于调试
        openserial_member_printf("Slot resource %d: Slot offset=%d, Channel offset=%d", 
                                j, 
                                cslot->slotOffset, 
                                cslot->channelOffset);
        // 这里应该调用注册时隙的函数
        // 例如: schedule_addActiveSlot(cslot.slotOffset, cslot.channelOffset, ...);
        if(member_vars.state == MEMBER_STATE_ACTIVE)
            member_vars.state = MEMBER_STATE_SCHEDULED;
    }

    // 成功注册，推入任务到调度队列
    //scheduler_push_task(task_execute, TASKPRIO_SIXTOP_NOTIF_RX);
    //DISABLE_INTERRUPTS();
    task_queue_enqueue(&queue, task);
    //ENABLE_INTERRUPTS();
    
    openserial_member_printf("Successfully registered task %d with %d slot resources", taskID, slotCount);

    // 3. 回复组长
    reply = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if (reply == NULL) {
        openserial_member_printf("Member: Failed to get packet buffer for task response");
        return;
    }
    
    packetfunctions_reserveHeader(&reply, 2);
    reply->payload[0] = taskID;
    reply->payload[1] = success ? 1 : 0; // 1表示成功，0表示失败
    
    memset(&reply->l2_nextORpreviousHop, 0, sizeof(open_addr_t));
    reply->l2_nextORpreviousHop.type = ADDR_64B;
    reply->l2_nextORpreviousHop.addr_64b[7] = msg->l2_nextORpreviousHop.addr_64b[7]; // 发送给leader
    
    openserial_member_printf("Member: Sending task ID=%d registration %s to leader ID=%d", 
                            taskID, success ? "SUCCESS" : "FAILURE", 
                            msg->l2_nextORpreviousHop.addr_64b[7]);
    
    if (sixtop_send(reply) == E_FAIL) {
        openqueue_freePacketBuffer(reply);
        openserial_member_printf("Reply sending failed");
    }
    return;
gg:
    member_tasks_vars.activeTaskCount--;
    member_tasks_vars.activeTasks[i].state = FREE;
}

void member_notifTaskProgress(task_struct* task) {
    OpenQueueEntry_t* pkt;
    uint8_t i;

    uint8_t efficiency = 80; // 假设发包效率为80%
    uint8_t utilization = 70; // 假设时隙利用率为70%
    
    DEBUG_PRINTF("member_notifTaskProgress: Starting to prepare task progress notification, task ID: %d", task->taskID);
    
    // 准备进度报告数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if (pkt == NULL) {
        DEBUG_PRINTF("member_notifTaskProgress: Unable to get packet buffer");
        openserial_member_printf("buffer fail");
        return;
    }
    
    // 填充进度报告
    packetfunctions_reserveHeader(&pkt, 4);
    pkt->payload[0] = task->taskID;
    pkt->payload[1] = task->progress;
    pkt->payload[2] = efficiency;
    pkt->payload[3] = utilization;
    
    DEBUG_PRINTF("member_notifTaskProgress: Filling progress report - Task ID: %d, Progress: %d%%, Efficiency: %d%%, Utilization: %d%%",
                task->taskID, task->progress, efficiency, utilization);
    
    // 配置单播到组长
    memset(&pkt->l2_nextORpreviousHop, 0, sizeof(open_addr_t));
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = task->leaderID;
    
    DEBUG_PRINTF("member_notifTaskProgress: Configuring send target leader ID: %d", task->leaderID);
    
    // 发送进度报告
    if (sixtop_send(pkt) == E_FAIL) {
        DEBUG_PRINTF("member_notifTaskProgress: Send failed");
        openqueue_freePacketBuffer(pkt);
        openserial_member_printf("send fail");
    } else {
        DEBUG_PRINTF("member_notifTaskProgress: Task progress notification sent successfully");
    }
}

void member_sendProgress(void){
    task_struct* task;
    uint8_t batch = MEMBER_TASKS_REPORT_BATCH;
    
    DEBUG_PRINTF("member_sendProgress: Starting to check if task progress needs to be sent");
    
    if(task_queue_isEmpty(&queue)){
        DEBUG_PRINTF("member_sendProgress: Queue is empty, no need to send progress report");
        return;
    }
    DEBUG_PRINTF("member_sendProgress: Queue not empty, preparing to send progress reports in batch, batch size: %d", batch);
    while(batch--){
        if(task_queue_loop(&queue, &task)){
            DEBUG_PRINTF("member_sendProgress: Sending progress report for task %d", task->taskID);
            member_notifTaskProgress(task);
        }
    }
}

// // 预定义的任务执行函数(这里只显示调度其他核，并将当前任务添加进报告队列中？)
// void task_execute(task_struct* task) {
//     DEBUG_PRINTF("task_execute: Starting to execute task %d", task->taskID);
    
//     if(task == NULL) {
//         DEBUG_PRINTF("task_execute: Error - Task is null");
//         openserial_member_printf("task is null");
//         return;
//     }
    
//     while(1) {
//         DEBUG_PRINTF("task_execute: Computing task progress: %d", task->progress);
//         openserial_member_printf("computing task progress: %d", task->progress);
        
//         // 检查任务是否完成
//         if(task->progress >= 100) {
//             DEBUG_PRINTF("task_execute: Task completed");
//             task->progress = 100;
//             openserial_member_printf("task completed");
//             // 任务完成后继续执行，等待新任务
//             task->progress = 0;
//             DEBUG_PRINTF("task_execute: Task progress reset to 0");
//         }
        
//         // 向组长报告任务进度
//         DEBUG_PRINTF("task_execute: Starting to report task progress");
//         member_notifTaskProgress(task);
        
//         // 添加延时，避免过于频繁执行
//         DEBUG_PRINTF("task_execute: Adding 1 second delay");
//         opentimers_scheduleIn(
//             member_vars.statusTimer,
//             1000,  // 1秒
//             TIME_MS,
//             TIMER_ONESHOT,
//             member_timer_cb
//         );
//     }
// }

/**
 * 初始化任务队列
 * @param queue 要初始化的队列
 */
void task_queue_init(task_queue_t* queue) {
    DEBUG_PRINTF("task_queue_init: Starting to initialize queue");
    
    queue->head = 0;
    queue->tail = 0;
    queue->size = 0;
    queue->capacity = MAX_QUEUED_TASKS;
    
    DEBUG_PRINTF("task_queue_init: Queue initialization complete, capacity: %d", queue->capacity);
}

/**
 * 检查队列是否为空
 * @param queue 要检查的队列
 * @return TRUE如果队列为空，否则FALSE
 */
bool task_queue_isEmpty(task_queue_t* queue) {
    bool isEmpty = queue->size == 0;
    DEBUG_PRINTF("task_queue_isEmpty: Queue is empty: %d", isEmpty);
    return isEmpty;
}

/**
 * 检查队列是否已满
 * @param queue 要检查的队列
 * @return TRUE如果队列已满，否则FALSE
 */
bool task_queue_isFull(task_queue_t* queue) {
    bool isFull = queue->size == queue->capacity;
    DEBUG_PRINTF("task_queue_isFull: Queue is full: %d", isFull);
    return isFull;
}

/**
 * 将任务添加到队列尾部
 * @param queue 目标队列
 * @param task 要添加的任务
 * @return TRUE如果添加成功，否则FALSE
 */
bool task_queue_enqueue(task_queue_t* queue, task_struct* task) {
    DEBUG_PRINTF("task_queue_enqueue: Attempting to enqueue task %d", task->taskID);
    
    if (task_queue_isFull(queue)) {
        DEBUG_PRINTF("task_queue_enqueue: Queue is full, enqueue failed");
        return FALSE;  // 队列已满
    }

    // 复制任务到队列尾部
    queue->tasks[queue->tail] = task;
        
    // 更新尾指针和大小
    queue->tail = (queue->tail + 1) % queue->capacity;
    queue->size++;
    
    DEBUG_PRINTF("task_queue_enqueue: Enqueue successful, current queue size: %d", queue->size);
    return TRUE;
}

/**
 * 从队列头部取出任务
 * @param queue 源队列
 * @param task 存放取出任务的指针
 * @return TRUE如果取出成功，否则FALSE
 */
bool task_queue_dequeue(task_queue_t* queue, task_struct** task) {
    DEBUG_PRINTF("task_queue_dequeue: Attempting to dequeue task from queue");
    
    if (task_queue_isEmpty(queue)) {
        DEBUG_PRINTF("task_queue_dequeue: Queue is empty, dequeue failed");
        return FALSE;  // 队列为空
    }
    
    // 队列头部任务
    *task = queue->tasks[queue->head];
    
    DEBUG_PRINTF("task_queue_dequeue: Dequeued task ID: %d", (*task)->taskID);

    // 更新头指针和大小
    queue->head = (queue->head + 1) % queue->capacity;
    queue->size--;
    
    DEBUG_PRINTF("task_queue_dequeue: Dequeue successful, current queue size: %d", queue->size);
    return TRUE;
}

/**
 * 查看队列头部任务但不移除
 * @param queue 源队列
 * @param task 存放查看任务的指针
 * @return TRUE如果查看成功，否则FALSE
 */
bool task_queue_peek(task_queue_t* queue, task_struct** task) {
    DEBUG_PRINTF("task_queue_peek: Attempting to peek at queue head task");
    
    if (task_queue_isEmpty(queue)) {
        DEBUG_PRINTF("task_queue_peek: Queue is empty, peek failed");
        return FALSE;  // 队列为空
    }
    
    //队列头部任务
    *task =  queue->tasks[queue->head];
    
    DEBUG_PRINTF("task_queue_peek: Peeked at task ID: %d", (*task)->taskID);
    return TRUE;
}

bool task_queue_loop(task_queue_t* queue, task_struct** task) {
    DEBUG_PRINTF("task_queue_loop: Attempting to loop dequeue task from queue");
    
    if (task_queue_isEmpty(queue)) {
        DEBUG_PRINTF("task_queue_loop: Queue is empty, loop dequeue failed");
        return FALSE;  // 队列为空
    }
    
    //队列头部任务
    *task =  queue->tasks[queue->head];
    queue->head = (queue->head + 1) % queue->size;
    
    DEBUG_PRINTF("task_queue_loop: Loop dequeued task ID: %d", (*task) ->taskID);
    return TRUE;
}


/**
 * 获取队列当前大小
 * @param queue 要查询的队列
 * @return 队列中的任务数量
 */
uint8_t task_queue_size(task_queue_t* queue) {
    DEBUG_PRINTF("task_queue_size: Current queue size: %d", queue->size);
    return queue->size;
}

/**
 * 清空队列
 * @param queue 要清空的队列
 */
void task_queue_clear(task_queue_t* queue) {
    DEBUG_PRINTF("task_queue_clear: Starting to clear queue");
    
    queue->head = 0;
    queue->tail = 0;
    queue->size = 0;
    
    DEBUG_PRINTF("task_queue_clear: Queue cleared");
}

slot_resource_t *task_findAvailSlots(slot_resource_t *slots, uint8_t max){
    uint8_t i;
    
    //DEBUG_PRINTF("task_findAvailSlots: Starting to find available slots");
    
    for(i=0; i<max; i++) {
        if(slots[i].type == CELLTYPE_OFF) {
            slots[i].type = CELLTYPE_TASK;
            //DEBUG_PRINTF("task_findAvailSlots: Found available slot %d", i);
            return &slots[i];
        }
    }
    
    //DEBUG_PRINTF("task_findAvailSlots: No available slots found");
    return NULL;
}

//找到的第一个非活动任务索引，如果没有找到则返回0xFF
uint8_t task_findFirstInactive(task_struct *tasks[], uint8_t maxTasks) {
    uint8_t i;
    
    DEBUG_PRINTF("task_findFirstInactive: Starting to find first inactive task");
    
    for (i = 0; i < maxTasks; i++) {
        // 检查任务是否存在且非活动
        if (tasks[i] != NULL && tasks[i]->active == FALSE) {
            DEBUG_PRINTF("task_findFirstInactive: Found inactive task, index %d", i);
            return i; 
        }
        if(tasks[i] == NULL){
            DEBUG_PRINTF("task_findFirstInactive: Found NULL task, index %d", i);
            return i;
        }
    }
    
    DEBUG_PRINTF("task_findFirstInactive: No inactive task found");
    return 0xFF;
}

task_struct * task_findFreeTaskContainer(task_struct *tasks, uint8_t maxTasks) {
    uint8_t i;
    
    DEBUG_PRINTF("task_findFreeTaskContainer: Starting to find free task container");
    
    if(!tasks){
        DEBUG_PRINTF("task_findFreeTaskContainer: Task array is null");
        return;
    }
    for (i = 0; i < maxTasks; i++) {
        // 检查任务是否存在且非活动
        if (tasks[i].active == FALSE) {
            tasks[i].active = TRUE;
            tasks[i].virID = i;
            DEBUG_PRINTF("task_findFreeTaskContainer: Found free task container, index %d, virtual ID %d", i, i);
            return &tasks[i]; 
        }    
    }
    DEBUG_PRINTF("task_findFreeTaskContainer: No free task container found");
    return NULL;
}
void task_freeTaskContainer(task_struct *task) {
    uint8_t i;
    
    DEBUG_PRINTF("task_freeTaskContainer: Starting to free task container");
    
    if(!task){
        DEBUG_PRINTF("task_freeTaskContainer: Error - Task pointer is null");
        openserial_mysf_printf("wrong: task_freeTaskContainer");
        return;
    }

    task->active = FALSE;
    DEBUG_PRINTF("task_freeTaskContainer: Task container freed, virtual ID %d", task->virID);
}


uint8_t task_getFreeTaskList() {
    uint8_t i,maxTasks;
    
    DEBUG_PRINTF("task_getFreeTaskList: Starting to find free task list");
    
    if(center_vars.role == CENTER_ROLE_LEADER){
        maxTasks=MAX_TASKS_PER_LEADER;
        for (i = 0; i < maxTasks; i++) {
            if (leader_tasks_vars.activeTasks[i].state == FREE) {
                DEBUG_PRINTF("task_getFreeTaskList: Found free leader task list, index %d", i);
                return i; 
            }   
        }
    }else{
        maxTasks=MAX_TASKS_PER_MEMBER;
        for (i = 0; i < maxTasks; i++) {
            if (member_tasks_vars.activeTasks[i].state == FREE) {
                DEBUG_PRINTF("task_getFreeTaskList: Found free member task list, index %d", i);
                return i; 
            }   
        }
    }
    
    DEBUG_PRINTF("task_getFreeTaskList: No free task list found");
    return maxTasks;
}


void task_rslotToSlot(slot_resource_t *slot, root_slot_resource_t *rslot,task_struct *task){
    // 复制基本信息
    //DEBUG_PRINTF("task_rslotToSlot: Starting to convert root slot to local slot");
    
    slot->slotOffset = rslot->slotOffset;
    slot->channelOffsetIndex = 0;
    slot->type = rslot->type;
    slot->numChannels = rslot->numChannels;
    slot->owner =  rslot->owner;

    slot->taskID = task->taskID;
    
    // DEBUG_PRINTF("task_rslotToSlot: Basic info - Slot offset: %d, Type: %d, Number of channels: %d", 
    //             slot->slotOffset, slot->type, slot->numChannels);

    // 初始化信道资源
    for (uint8_t j = 0; j < rslot->numChannels && j < MAX_CHANNELS_PER_SLOT; j++) {
        slot->channels[j].channelOffset = rslot->channelOffsets[j];
        slot->channels[j].isActive = TRUE;
        slot->channels[j].currentQuality = 100; // 初始质量设为最高
        slot->channels[j].lastSwitchTime = 0;
        slot->channels[j].historyIndex = 0;
        
        // DEBUG_PRINTF("task_rslotToSlot: Setting channel %d offset to %d", 
        //            j, slot->channels[j].channelOffset);
        
        // 初始化质量历史记录
        memset(slot->channels[j].qualityHistory, 0, 
                sizeof(channel_quality_record_t) * QUALITY_HISTORY_SIZE);
    }
    
    // DEBUG_PRINTF("task_rslotToSlot: Slot conversion complete");
}

/**
 * 将slot_resource_t转换为center_slot_t
 * 
 * @param slot  源时隙资源结构
 * @param cslot 目标中心时隙结构
 */
void task_slotToCslot(slot_resource_t *slot, center_slot_t *cslot) {
    // 复制基本信息
    DEBUG_PRINTF("task_slotToCslot: Starting to convert local slot to center slot");
    
    cslot->slotOffset = slot->slotOffset;
    cslot->type = slot->type;
    cslot->owner = slot->owner;
    
    DEBUG_PRINTF("task_slotToCslot: Basic info - Slot offset: %d, Type: %d, Owner: %d", 
                cslot->slotOffset, cslot->type, cslot->owner);
    
    // 获取当前使用的信道偏移
    if (slot->numChannels > 0 && slot->channelOffsetIndex < slot->numChannels) {
        cslot->channelOffset = slot->channels[slot->channelOffsetIndex].channelOffset;
        DEBUG_PRINTF("task_slotToCslot: Setting channel offset to %d", cslot->channelOffset);
    } else {
        // 如果没有可用信道，设置为0
        cslot->channelOffset = 0;
        DEBUG_PRINTF("task_slotToCslot: Error - No available channel");
        openserial_mysf_printf("task_slotToCslot wrong");
    }
    
    DEBUG_PRINTF("task_slotToCslot: Slot conversion complete");
}

void task_mayStart(void) {
    task_struct *task;
    task_struct *nextTask;
    bool canStartTask = FALSE;

    DEBUG_PRINTF("task_mayStart: Checking if there are tasks that can be started");

    // 检查队列中是否有任务且空闲成员足够
    canStartTask = task_queue_peek(&queue, &task) && 
                  (leader_vars.freeMembers >= task->memberCount);

    if (!canStartTask) {
        if (task_queue_isEmpty(&queue)) {
            DEBUG_PRINTF("task_mayStart: Queue is empty, no tasks to start");
        } else {
            DEBUG_PRINTF("task_mayStart: Not enough free members to start tasks in queue");
        }
        return;
    }

    DEBUG_PRINTF("task_mayStart: Found task that can be started, ID: %d, Free members: %d, Required members: %d",
               task->taskID, leader_vars.freeMembers, task->memberCount);

    // 从队列中取出任务
    if (!task_queue_dequeue(&queue, &task)) {
        DEBUG_PRINTF("task_mayStart: Task dequeue failed");
        openserial_leader_printf("free members:%d, next task members:%d", 
                               leader_vars.freeMembers, task->memberCount);
        return;
    }

    // 检查下一个任务是否需要EB
    if (task_queue_peek(&queue, &nextTask)) {
        leader_vars.ebEnabled = leader_tasks_vars.activeTasks[nextTask->indexTbl].ebEnabled;
        DEBUG_PRINTF("task_mayStart: Next task in queue %s EB", 
                    leader_vars.ebEnabled ? "requires" : "does not require");
    } else {
        leader_vars.ebEnabled = FALSE;
        DEBUG_PRINTF("task_mayStart: No more tasks in queue, disabling EB");
    }
    
    // 尝试分配任务
    if (leader_assignTaskPrepare(task)) {
        DEBUG_PRINTF("task_mayStart: Task started successfully");
    } else {
        DEBUG_PRINTF("task_mayStart: Task start failed");
    }
}

task_struct* task_findTaskByID(uint8_t taskID)
{
    DEBUG_PRINTF("task_findTaskByID: Starting to find task ID: %d", taskID);
    
    for(uint8_t i = 0; i < MAX_TASKS_PER_LEADER * MAX_LEADERS; i++){
        if(tasks[i].active && tasks[i].taskID == taskID){
            DEBUG_PRINTF("task_findTaskByID: Task found, index: %d", i);
            return &tasks[i];
        }
    }
    
    DEBUG_PRINTF("task_findTaskByID: Task not found, ID: %d", taskID);
    return NULL;
}

task_struct* task_getGlobalTask(){
    DEBUG_PRINTF("task_getGlobalTask: Returning global task array pointer");
    return tasks;
}

task_struct* task_getPredefinedTask(uint8_t index){
    DEBUG_PRINTF("task_getPredefinedTask: Returning predefined task array pointer");
    return &predefined_tasks[index];
}

/**
 * 释放根节点角色的所有资源
 */
static void task_freeRootResources(void) {
    uint8_t i, j;
    
    DEBUG_PRINTF("task_freeRootResources: Starting to free ROOT resources");
    
    // 1. 清空任务队列
    task_queue_clear(&queue);
    
    
    // 3. 重置根节点任务管理变量
    root_tasks_vars.activeTaskCount = 0;
    root_tasks_vars.queuedTaskCount = 0;
    
    // 4. 重置每个组长的任务管理
    for (i = 0; i < MAX_LEADERS; i++) {
        root_tasks_vars.leaders[i].taskCount = 0;
        root_tasks_vars.leaders[i].queuedTaskCount = 0;
        root_tasks_vars.leaders[i].completedTaskCount = 0;
        root_tasks_vars.leaders[i].failedTaskCount = 0;
        for (j = 0; j < MAX_SLOT_RESOURCES; j++) {
            // Convert root_slot_resource_t to slot_resource_t and store
            root_tasks_vars.leaders[i].leader->resource.slots[j].type = CELLTYPE_OFF;
            
            // DEBUG_PRINTF("root_assignTask: resourse added, [slot %d, channel count %d]", 
            //             resource[i].slotOffset, resource[i].numChannels);
        }
        root_tasks_vars.leaders[i].leader->resource.numSlots = 0;

        // 清空任务数组
        for (j = 0; j < MAX_TASKS_PER_LEADER; j++) {
            root_tasks_vars.leaders[i].tasks[j] = NULL;
        }
    }
    // 2. 释放所有任务容器
    for (i = 0; i < MAX_TASKS_PER_LEADER * MAX_LEADERS; i++) {
        if (tasks[i].active) {
            // 使用root_releaseTaskResources函数释放资源
            root_releaseTaskResources(i);
        }
    }

    DEBUG_PRINTF("task_freeRootResources: ROOT resources freed successfully");
}

/**
 * 释放组长角色的所有资源
 */
static void task_freeLeaderResources(void) {
    uint8_t i;
    
    DEBUG_PRINTF("task_freeLeaderResources: Starting to free LEADER resources");
    
    // 1. 清空任务队列
    task_queue_clear(&queue);
    
    // 2. 释放所有任务容器
    for (i = 0; i < MAX_TASKS_PER_LEADER * MAX_LEADERS; i++) {
        if (tasks[i].active) {
            task_freeTaskContainer(&tasks[i]);
        }
    }
    
    // 3. 重置组长任务管理变量
    leader_tasks_vars.activeTaskCount = 0;
    
    // 4. 重置活动任务列表
    for (i = 0; i < MAX_TASKS_PER_LEADER; i++) {
        leader_tasks_vars.activeTasks[i].task = NULL;
        leader_tasks_vars.activeTasks[i].memberCount = 0;
        leader_tasks_vars.activeTasks[i].ebEnabled = FALSE;
        leader_tasks_vars.activeTasks[i].state = FREE;
        
        // 清空成员数组
        memset(leader_tasks_vars.activeTasks[i].members, 0, MAX_MEMBERS_PER_TASK);
    }
    
    // 5. 释放时隙资源
    for (i = 0; i < MAX_SLOT_RESOURCES; i++) {
        leader_vars.resourceManager.slots[i].type = CELLTYPE_OFF;
    }
    
    DEBUG_PRINTF("task_freeLeaderResources: LEADER resources freed successfully");
}

/**
 * 释放成员角色的所有资源
 */
static void task_freeMemberResources(void) {
    uint8_t i;
    
    DEBUG_PRINTF("task_freeMemberResources: Starting to free MEMBER resources");
    
    // 1. 清空任务队列
    task_queue_clear(&queue);
    
    // 2. 释放所有任务容器
    for (i = 0; i < MAX_TASKS_PER_LEADER * MAX_LEADERS; i++) {
        if (tasks[i].active) {
            task_freeTaskContainer(&tasks[i]);
        }
    }
    
    // 3. 重置成员任务管理变量
    member_tasks_vars.activeTaskCount = 0;
    
    // 4. 重置活动任务列表
    for (i = 0; i < MAX_TASKS_PER_MEMBER; i++) {
        member_tasks_vars.activeTasks[i].task = NULL;
        member_tasks_vars.activeTasks[i].state = FREE;
        
        // 清空时隙资源
        memset(member_tasks_vars.activeTasks[i].slotResources, 0, MAX_SLOTS_PER_TASK);
    }
    
    DEBUG_PRINTF("task_freeMemberResources: MEMBER resources freed successfully");
}

/**
 * 根据节点角色释放所有相关资源
 */
void task_freeAll(void) {
    DEBUG_PRINTF("task_freeAll: Starting to free all resources based on node role");
    
    // 根据节点角色释放资源
    if (center_vars.role == CENTER_ROLE_ROOT) {
        task_freeRootResources();
    } else if (center_vars.role == CENTER_ROLE_LEADER) {
        task_freeLeaderResources();
    } else if (center_vars.role == CENTER_ROLE_MEMBER) {
        task_freeMemberResources();
    } else {
        DEBUG_PRINTF("task_freeAll: Unknown role, no resources to free");
    }
    
    DEBUG_PRINTF("task_freeAll: All resources freed successfully");
}

/**
 * 打印当前角色所有资源的状态
 */
void task_showAll(void) {
    uint8_t i;
    
    DEBUG_PRINTF("task_showAll: Starting to show all resources for current role");
    
    // 根据节点角色显示资源
    if (center_vars.role == CENTER_ROLE_ROOT) {
        // 显示ROOT角色资源
        DEBUG_PRINTF("=== ROOT Resources Status ===");
        DEBUG_PRINTF("Active Tasks: %d", root_tasks_vars.activeTaskCount);
        DEBUG_PRINTF("Queued Tasks: %d", root_tasks_vars.queuedTaskCount);
        
        // 显示每个组长的任务状态
        for (i = 0; i < MAX_LEADERS; i++) {
            DEBUG_PRINTF("Leader %d:", i);
            DEBUG_PRINTF("  Task Count: %d", root_tasks_vars.leaders[i].taskCount);
            DEBUG_PRINTF("  Queued Tasks: %d", root_tasks_vars.leaders[i].queuedTaskCount);
            DEBUG_PRINTF("  Completed Tasks: %d", root_tasks_vars.leaders[i].completedTaskCount);
            DEBUG_PRINTF("  Failed Tasks: %d", root_tasks_vars.leaders[i].failedTaskCount);
        }

        // 显示全局时隙资源状态
        DEBUG_PRINTF("Global Slot Resources: 1 means available, 0 means unavailable");
        for (i = 0; i < MAX_GLOBAL_SLOTS; i++) {
            if (i < MAX_GLOBAL_SLOTS) {
                // 将64位channelBitmap拆分为4个16位段分别打印
                uint16_t bitmap_part1 = (uint16_t)(root_vars.slotResource.slots[i].channelBitmap & 0xFFFF);
                uint16_t bitmap_part2 = (uint16_t)((root_vars.slotResource.slots[i].channelBitmap >> 16) & 0xFFFF);
                uint16_t bitmap_part3 = (uint16_t)((root_vars.slotResource.slots[i].channelBitmap >> 32) & 0xFFFF);
                uint16_t bitmap_part4 = (uint16_t)((root_vars.slotResource.slots[i].channelBitmap >> 48) & 0xFFFF);
                openserial_root_printf("时隙位图: slot=%d p1=0x%x%x%x%x channels=%d", 
                                    i,
                                    bitmap_part4,
                                    bitmap_part3, 
                                    bitmap_part2,
                                    bitmap_part1,
                                    root_vars.slotResource.slots[i].numChannels);
            }
        }
        
    } else if (center_vars.role == CENTER_ROLE_LEADER) {
        // 显示LEADER角色资源
        DEBUG_PRINTF("=== LEADER Resources Status ===");
        DEBUG_PRINTF("Active Tasks: %d", leader_tasks_vars.activeTaskCount);
        
        // 显示活动任务列表
        for (i = 0; i < MAX_TASKS_PER_LEADER; i++) {
            if (leader_tasks_vars.activeTasks[i].state != FREE) {
                DEBUG_PRINTF("Task Index %d:", i);
                DEBUG_PRINTF("  State: %d", leader_tasks_vars.activeTasks[i].state);
                DEBUG_PRINTF("  Member Count: %d", leader_tasks_vars.activeTasks[i].memberCount);
                DEBUG_PRINTF("  EB Enabled: %d", leader_tasks_vars.activeTasks[i].ebEnabled);
            }
        }
        
        // 显示本地时隙资源状态
        DEBUG_PRINTF("Local Slot Resources:");
        for (i = 0; i < MAX_SLOT_RESOURCES; i++) {
            if (leader_vars.resourceManager.slots[i].type != CELLTYPE_OFF) {
                DEBUG_PRINTF("  Slot %d: Type=%d, Channels=%d", 
                           i,
                           leader_vars.resourceManager.slots[i].type,
                           leader_vars.resourceManager.slots[i].numChannels);
            }
        }
        
    } else if (center_vars.role == CENTER_ROLE_MEMBER) {
        // 显示MEMBER角色资源
        DEBUG_PRINTF("=== MEMBER Resources Status ===");
        DEBUG_PRINTF("Active Tasks: %d", member_tasks_vars.activeTaskCount);
        
        // 显示活动任务列表
        for (i = 0; i < MAX_TASKS_PER_MEMBER; i++) {
            if (member_tasks_vars.activeTasks[i].state != FREE) {
                DEBUG_PRINTF("Task Index %d:", i);
                DEBUG_PRINTF("  State: %d", member_tasks_vars.activeTasks[i].state);
                DEBUG_PRINTF("  Slot Resources: %d", member_tasks_vars.activeTasks[i].slotResources[0]);
            }
        }
        
    } else {
        DEBUG_PRINTF("task_showAll: Unknown role, no resources to show");
    }
    
    DEBUG_PRINTF("task_showAll: Resource status display completed");
}

