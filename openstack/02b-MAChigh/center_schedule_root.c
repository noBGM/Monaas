#include "center_schedule_root.h"
#include "center_schedule_tasks.h"

root_vars_t root_vars;

//=========================== 原型 =========================================

static void root_task_cb(void);
static void root_sendToPC(uint8_t* data, uint8_t len);
static void root_handleControl(uint8_t* data, uint8_t len);
static void root_handleSchedule(uint8_t* data, uint8_t len);
static void root_handleResourceConfig(uint8_t* data, uint8_t len);
static void root_sendStartCommand(void);
static void root_handleScheduleAck(OpenQueueEntry_t* msg);
static void root_handleStartAck(OpenQueueEntry_t* msg);
static void root_processSensorData(OpenQueueEntry_t* msg);
static void root_updateLeaderState(uint16_t leaderId, OpenQueueEntry_t* msg);
static void root_notifyLeaderStateChange(leader_monitor_t* leader);
static void root_checkLeaderStatus(void);
static void root_handleStateReport(OpenQueueEntry_t* msg);
static void root_handleError(OpenQueueEntry_t* msg);
static void root_handleMacTest(uint8_t* data, uint8_t len);
static void root_handleMacTestResponse(OpenQueueEntry_t* msg);
static void root_timer_cb(opentimers_id_t id);



group_resource_manager_t groupResourceManagers[CENTER_MAX_GROUPS];
//=========================== 公共函数 =====================================

/**
\brief Root节点初始化时隙分配
*/
static void root_initSchedule(void) {
    uint8_t i;
    center_slot_t slot;
    open_addr_t neighbor;
    
    // 初始化邻居地址
    
    memset(&neighbor, 0, sizeof(open_addr_t));
    
    // 为每个Leader分配上行和下行时隙，信道偏移为0
    uint8_t group_id = CENTER_GROUP_HEAD;
    for(i = 0; i < CENTER_MAX_GROUPS; i++, group_id++) {
        // 上行时隙(Leader->Root)
        slot.slotOffset = CENTER_SLOT_UPLINK + i;
        slot.channelOffset = 0;
        slot.type = CELLTYPE_RX;  // Root接收
        neighbor.type = ADDR_64B;
        neighbor.addr_64b[7] = group_id;  // Leader ID从0开始
        
        if(schedule_addActiveSlot(
            slot.slotOffset,
            slot.type,
            FALSE,          // 非共享
            FALSE,          
            slot.channelOffset,
            &neighbor
        ) != E_SUCCESS) {
            // 错误处理
            continue;
        }
        
        // 记录时隙状态
        center_vars.slots[slot.slotOffset].isUsed = TRUE;
        center_vars.slots[slot.slotOffset].ownerId = group_id;
        center_vars.slots[slot.slotOffset].type = slot.type;
        
        // 下行时隙(Root->Leader)
        slot.slotOffset = CENTER_SLOT_DOWNLINK + i;
        slot.type = CELLTYPE_TX;  // Root发送
        
        if(schedule_addActiveSlot(
            slot.slotOffset,
            slot.type,
            FALSE,          // 非共享
            FALSE,          
            slot.channelOffset,
            &neighbor
        ) != E_SUCCESS) {
            // 错误处理
            continue;
        }
        
        // 记录时隙状态
        center_vars.slots[slot.slotOffset].isUsed = TRUE;
        center_vars.slots[slot.slotOffset].ownerId = group_id;
        center_vars.slots[slot.slotOffset].type = slot.type;
    }
}

/**
\brief Root节点初始化
*/
void center_init_root(void) {
    // 重置变量
    memset(&root_vars, 0, sizeof(root_vars_t));
    
    // 设置角色
    center_vars.role = CENTER_ROLE_ROOT;
    center_vars.myId = ROOT_ID;//idmanager_getMyID(ADDR_64B)->addr_64b[7];
    idmanager_getMyID(ADDR_64B)->addr_64b[7] = center_vars.myId;
    memset(&center_vars.myId_addr, 0, sizeof(center_vars.myId_addr));
    center_vars.myId_addr.addr_64b[7] = center_vars.myId;
    center_vars.myId_addr_16.addr_16b[0] = 0x00;
    center_vars.myId_addr_16.addr_16b[1] = center_vars.myId_addr.addr_64b[7];
    center_vars.myId_addr.type = ADDR_64B;
    center_vars.myId_addr_16.type = ADDR_16B;
    idmanager_setMyID(&center_vars.myId_addr);
    idmanager_setMyID(&center_vars.myId_addr_16);
    // 初始化时隙分配
    root_initSchedule();
    root_initTaskHandler();

    // 初始化状态检查定时器
    root_vars.statusTimer = opentimers_create(TIMER_GENERAL_PURPOSE, TASKPRIO_COAP);
    opentimers_scheduleIn(
        root_vars.statusTimer,
        ROOT_CHECK_PERIOD,
        TIME_MS,
        TIMER_PERIODIC,
        root_timer_cb
    );
}

/**
\brief 定时器回调函数
*/
static void root_timer_cb(opentimers_id_t id) {
    root_task_cb();
}

/**
\brief 处理接收到的数据帧
*/
void center_root_receiveFrame(OpenQueueEntry_t* msg) {
    uint8_t frameType;
    uint8_t cmdType;
    uint16_t srcId;
    
    openserial_root_printf("center_root_receiveFrame");
    // 提取帧类型和源节点ID
    frameType = msg->payload[0];
    srcId = msg->l2_nextORpreviousHop.addr_64b[7];
    packetfunctions_tossHeader(&msg,1);

    // 更新Leader状态
    //root_updateLeaderState(srcId, msg);
    
    switch(frameType) {
        case CENTER_FRAME_DATA:
            // 处理数据帧
            center_data_header_t* header = (center_data_header_t*)msg->payload;
            switch(header->type) {
                case CENTER_DATA_SENSOR:
                    root_processSensorData(msg);
                    break;
                    
                default:
                    // 其他类型数据直接转发到PC
                    root_sendToPC(msg->payload, msg->length);
                    break;
            }
            break;
            
        case CENTER_FRAME_COMMAND:
            cmdType = msg->payload[0];
            packetfunctions_tossHeader(&msg,1);
            switch(cmdType) {
                case CENTER_CMD_SCHED_ACK:
                    root_handleScheduleAck(msg);
                    break;
                case CENTER_CMD_START_ACK:
                    root_handleStartAck(msg);
                    break;
                case CENTER_CMD_MACTEST_RESP:
                    root_handleMacTestResponse(msg);
                    break;
                case CENTER_CMD_TASK_PROGRESS:
                    root_handleTaskProgress(msg);
                    break;
                case CENTER_CMD_TASK_RESP:
                    root_handleTaskResponse(msg);
                    break;
                default:
                    break;
            }
            break;
            
        case CENTER_FRAME_EVENT:
            cmdType = msg->payload[1];
            switch(cmdType) {
                case CENTER_EVENT_ERROR:
                    root_handleError(msg);
                    break;
                case CENTER_EVENT_STATE_CHANGE:
                    root_handleStateReport(msg);
                    break;
                default:
                    break;
            }
            
        default:
            break;
    }
    
    // 释放消息缓冲
    openqueue_freePacketBuffer(msg);
}

/**
\brief Root节点处理发送完成事件
\param msg 已发送的数据包
*/
void center_root_sendFrame(OpenQueueEntry_t* msg) {
    uint8_t frameType;
    uint8_t cmdType;
    
    // 提取帧类型
    openserial_mysf_printf("pkt sent done, %s",msg->l2_sendDoneError? "FAIL":"SUCCESS");
    frameType = msg->l2_payload[0];
    
    switch(frameType) {
        case CENTER_FRAME_COMMAND:
            cmdType = msg->l2_payload[1];
            switch(cmdType) {
                case CENTER_CMD_MACTEST:
                    // MAC测试命令发送完成
                    mac_test_pkt_t* testPkt = (mac_test_pkt_t*)&msg->l2_payload[2];
                    openserial_mysf_printf("MAC test sent to group %d target %d, dsn:%d", 
                                         testPkt->groupId,
                                         testPkt->targetId,
                                         msg->l2_dsn);
                    break;
                    
                case CENTER_CMD_SCHEDULE:
                    // 调度表更新命令发送完成
                    openserial_mysf_printf("Schedule update sent");
                    break;
                    
                case CENTER_CMD_START:
                    // 启动命令发送完成
                    openserial_mysf_printf("Start command sent");
                    break;
                    
                default:
                    break;
            }
            break;
            
        case CENTER_FRAME_DATA:
            // 数据帧发送完成
            center_data_header_t* header = (center_data_header_t*)msg->payload;
            switch(header->type) {
                case CENTER_DATA_SENSOR:
                    openserial_mysf_printf("Sensor data forwarded");
                    break;
                    
                case CENTER_DATA_STATUS:
                    openserial_mysf_printf("Status data forwarded");
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    // 释放消息缓冲
    openqueue_freePacketBuffer(msg);
    openserial_mysf_printf("free pkt");

}

//=========================== 私有函数 =====================================

/**
\brief 根节点任务回调函数
*/
static void root_task_cb(void) {
    // 检查Leader状态
    root_checkLeaderStatus();
}

/**
\brief 发送数据到PC
*/
static void root_sendToPC(uint8_t* data, uint8_t len) {
    uint8_t pcBuf[SERIAL_OUTPUT_BUFFER_SIZE];
    uint8_t pcLen = 0;
    
    // 添加头部
    pcBuf[pcLen++] = CENTER_FRAME_DATA;
    
    // 复制数据
    memcpy(&pcBuf[pcLen], data, len);
    pcLen += len;
    
    // 通过串口发送
    openserial_printData(pcBuf, pcLen);
}

/**
\brief 处理PC命令
*/
void root_handleCommand(uint8_t* data, uint8_t len) {
    root_cmd_type_t cmdType;
    
    //if(len < 2) return;
    
    cmdType = (root_cmd_type_t)data[0];
    switch(cmdType) {
        case ROOT_CMD_SCHEDULE:
            // 分发调度表
            //root_handleSchedule(&data[1], len-1);
            root_handleResourceConfig(&data[1], len-1);
            break;
            
        case ROOT_CMD_CONTROL:
            // 处理控制命令
            root_handleControl(&data[1], len-1);
            break;
            
        case ROOT_CMD_QUERY:
            // 处理查询命令
            break;
        case ROOT_CMD_MACTEST:
            openserial_mysf_printf("ROOT_CMD_MACTEST");
            root_handleMacTest(&data[1], len-1);
            break;
        case ROOT_CMD_TASK:
            //openserial_mysf_printf("ROOT_CMD_MACTEST");
            task_struct* tasks = task_getGlobalTask();
            task_struct* task = task_findFreeTaskContainer(tasks, MAX_TASKS_PER_LEADER * MAX_LEADERS);
            uint8_t index = data[1];
            openserial_mysf_printf("ROOT_CMD_TASK,index = %d",index);
            task_struct* predefined_tasks = task_getPredefinedTask(index);
            task->type = predefined_tasks->type;
            task->constraint = predefined_tasks->constraint;
            task->progress = predefined_tasks->progress;
            task->compatibleMask = predefined_tasks->compatibleMask;
            //task->taskID = data[2];
            root_handleTask(task);
            break;
        case ROOT_CMD_TASK_CLEAR:
            task_freeAll();
            break;
        default:
            break;
    }
}

/**
\brief 处理控制命令
*/
static void root_handleControl(uint8_t* data, uint8_t len) {
    uint8_t ctrlType;
    
    if(len < 1) return;
    
    ctrlType = data[0];
    switch(ctrlType) {
        case CENTER_CMD_START:
            root_sendStartCommand();
            break;
            
        default:
            break;
    }
}

/**
\brief 发送启动命令到所有Leader
*/
static void root_sendStartCommand(void) {
    OpenQueueEntry_t* pkt;
    uint8_t i;
    
    uint8_t group_id = CENTER_GROUP_HEAD;
    // 遍历所有组
    for(i=0; i<CENTER_MAX_GROUPS; i++) {
        if(root_vars.leaders[i].leaderId == 0) continue;
        
        // 分配数据包
        pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
        if(pkt == NULL) {
            // 发送错误事件到PC
            uint8_t errBuf[5];
            errBuf[0] = CENTER_FRAME_EVENT;
            errBuf[1] = CENTER_EVENT_ERROR;
            errBuf[2] = ERR_CENTER_BUFFER_FULL;
            errBuf[3] = 0;
            errBuf[4] = 0;
            openserial_printData(errBuf, 5);
            return;
        }
        
        // 为头部预留空间
        if(packetfunctions_reserveHeader(&pkt, 2) == E_FAIL) {
            openqueue_freePacketBuffer(pkt);
            return;
        }
        
        // 填充头部
        pkt->payload[0] = CENTER_FRAME_COMMAND;
        pkt->payload[1] = CENTER_CMD_START;
        //pkt->length = 2;
        
        // 发送到Leader
        pkt->l2_nextORpreviousHop.type = ADDR_64B;
        pkt->l2_nextORpreviousHop.addr_64b[7] = root_vars.leaders[i].leaderId;
        
        if(sixtop_send(pkt) != E_SUCCESS) {
            openqueue_freePacketBuffer(pkt);
        } else {
            root_vars.pendingAcks++;
        }
    }
}




/**
\brief 处理来自PC的调度资源配置，会覆盖上一次的配置。
\param[in] data 包含调度资源配置的数据(时隙起始，时隙结束，信道起始，信道结束，不可用时隙1，不可用信道1,不可用时隙2，不可用信道2,...)
\param[in] len 数据长度
*/
static void root_handleResourceConfig(uint8_t* data, uint8_t len) {
    uint8_t slotStart, slotEnd, channelStart, channelEnd;
    uint8_t unavailableSlot, unavailableChannel;
    uint8_t i, j, index;
    
    // 检查数据长度是否合法
    if (len < 4) {
        openserial_root_printf("错误：资源配置数据长度不足");
        return;
    }
    
    // 解析基本参数
    slotStart = data[0];
    slotEnd = data[1];
    channelStart = data[2];
    channelEnd = data[3];
    
    // 检查参数合法性
    if (slotEnd < slotStart || channelEnd < channelStart || 
        slotEnd >= MAX_GLOBAL_SLOTS || channelEnd >= MAX_GLOBAL_CHANNELS) {
        openserial_root_printf("错误：资源配置参数范围非法");
        return;
    }
    root_vars.slotResource.start = slotStart;
    root_vars.slotResource.end = slotEnd;
    
    // 初始化全局资源位图
    for (i = slotStart; i <= slotEnd; i++) {
        root_vars.slotResource.slots[i].channelBitmap = 0xFFFFFFFFFFFFFFFFULL; // 所有信道初始可用
        // 仅保留有效信道位
        root_vars.slotResource.slots[i].channelBitmap &= ((1ULL << (channelEnd + 1)) - 1);
        // 清除低于起始信道的位
        root_vars.slotResource.slots[i].channelBitmap &= ~((1ULL << channelStart) - 1);
        
        root_vars.slotResource.slots[i].numChannels = channelEnd - channelStart + 1;

    }
    
    // 更新可用时隙数量
    root_vars.slotResource.numSlots = slotEnd - slotStart + 1;
    
    // 处理不可用的时隙和信道
    index = 4;
    while (index < len) {
        unavailableSlot = data[index];
        unavailableChannel = data[index+1];
        index += 2;
        
        // 检查参数合法性
        if (unavailableSlot >= slotStart && unavailableSlot <= slotEnd &&
            unavailableChannel >= channelStart && unavailableChannel <= channelEnd) {
            // 将指定的时隙和信道标记为不可用
            root_vars.slotResource.slots[unavailableSlot].channelBitmap &= ~(1ULL << unavailableChannel);
            root_vars.slotResource.slots[unavailableSlot].numChannels--;
        }
    }
    
    // 打印资源配置信息
    openserial_root_printf("资源配置完成：时隙[%d-%d]，信道[%d-%d]，可用时隙数：%d", 
                          slotStart, slotEnd, channelStart, channelEnd, 
                          root_vars.slotResource.numSlots);
    
    // // 打印所有时隙的信道位图（调试用）
    // for (i = slotStart; i <= slotEnd; i++) {
    //     if (i < MAX_GLOBAL_SLOTS) {
    //         // 将64位channelBitmap拆分为4个16位段分别打印
    //         uint16_t bitmap_part1 = (uint16_t)(root_vars.slotResource.slots[i].channelBitmap & 0xFFFF);
    //         uint16_t bitmap_part2 = (uint16_t)((root_vars.slotResource.slots[i].channelBitmap >> 16) & 0xFFFF);
    //         uint16_t bitmap_part3 = (uint16_t)((root_vars.slotResource.slots[i].channelBitmap >> 32) & 0xFFFF);
    //         uint16_t bitmap_part4 = (uint16_t)((root_vars.slotResource.slots[i].channelBitmap >> 48) & 0xFFFF);
    //         openserial_root_printf("时隙位图: slot=%d p1=0x%x%x%x%x channels=%d", 
    //                             i,
    //                             bitmap_part4,
    //                             bitmap_part3, 
    //                             bitmap_part2,
    //                             bitmap_part1,
    //                             root_vars.slotResource.slots[i].numChannels);
    //     }
    // }
}





/**
 * numEntry=500,group0=122,group1=128,group2=124,group3=126
 * 或
 * numEntry=500,group0=0,group1=0,group2=200,group3=300
 * {entry0:slotoff,type,numchannels,channeloff},
 * {entry1:slotoff,type,numchannels,channeloff},
 * ...
 * {entry499:slotoff,type,numchannels,channeloff},
\brief 处理并分发调度表
*/
static void root_handleSchedule(uint8_t* data, uint8_t len) {
    center_schedule_header_t* header;
    OpenQueueEntry_t* pkt;
    uint8_t i, j, k, index, numEntry, group[CENTER_MAX_GROUPS];
    root_slot_resource_t* slots;
    // 定义全局资源管理器
    
    openserial_root_printf("root_handleSchedule,len = %d",len);
    // 解析头部
    //header = (center_schedule_header_t*)data;
    numEntry = data[0];
    group[0] = data[1]; //时隙数，不是cell数。
    group[1] = data[2];
    group[2] = data[3];
    group[3] = data[4];
    slots = (root_slot_resource_t*) &data[5];

    // if(numEntry > CENTER_MAX_GROUPS){
    //     openserial_root_printf("wrong:numEntry");
    //     return;
    // }
    
    // 初始化资源管理器
    for (i = 0; i < CENTER_MAX_GROUPS; i++) {
        groupResourceManagers[i].numSlots = 0;
        groupResourceManagers[i].groupId = i + CENTER_GROUP_HEAD;
    }
    
    // 将root_slot_resource_t转换为slot_resource_t并存储在资源管理器中
    for (i = 0, index = 0; i < CENTER_MAX_GROUPS; i++) {
        if (group[i] == 0) continue;
        
        for (j = 0; j < group[i]; j++) {
            slot_resource_t* slot = &groupResourceManagers[i].slots[j];
            root_slot_resource_t* rootSlot = &slots[index + j];
            
            // 复制基本信息
            slot->slotOffset = rootSlot->slotOffset;
            slot->type = rootSlot->type;
            slot->numChannels = rootSlot->numChannels;
            slot->owner = 0; // 初始无所有者
            
            // 初始化信道资源
            for (k = 0; k < rootSlot->numChannels && k < MAX_CHANNELS_PER_SLOT; k++) {
                slot->channels[k].channelOffset = rootSlot->channelOffsets[k];
                slot->channels[k].isActive = TRUE;
                slot->channels[k].currentQuality = 100; // 初始质量设为最高
                slot->channels[k].lastSwitchTime = 0;
                slot->channels[k].historyIndex = 0;
                
                // 初始化质量历史记录
                memset(slot->channels[k].qualityHistory, 0, sizeof(channel_quality_record_t) * QUALITY_HISTORY_SIZE);
            }
        }
        
        groupResourceManagers[i].numSlots = group[i];
        index += group[i];
    }
    
    // 遍历所有组，发送调度表
    for(i = 0, index = 0; i<CENTER_MAX_GROUPS; i++) {
        if(group[i] == 0) continue;
        
        // 分配数据包
        pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
        if(pkt == NULL) {
            // // 发送错误事件到PC
            // uint8_t errBuf[5];
            // errBuf[0] = CENTER_FRAME_EVENT;
            // errBuf[1] = CENTER_EVENT_ERROR;
            // errBuf[2] = ERR_CENTER_BUFFER_FULL;
            // errBuf[3] = 0;
            // errBuf[4] = 0;
            // openserial_printData(errBuf, 5);
            openserial_root_printf("wrong:getFreePktBuf");
            return;
        }
        
        // 为调度数据预留空间
        if(packetfunctions_reserveHeader(&pkt, group[i] * sizeof(root_slot_resource_t)) == E_FAIL) {
            openqueue_freePacketBuffer(pkt);
            openserial_root_printf("wrong:reserveHeader0");
            return;
        }
        
        // 复制调度数据
        memcpy(pkt->payload, &slots[index], group[i] * sizeof(root_slot_resource_t));
        index += group[i];

        if(packetfunctions_reserveHeader(&pkt, sizeof(center_schedule_header_t)) == E_FAIL) {
            openqueue_freePacketBuffer(pkt);
            openserial_root_printf("wrong:reserveHeader1");
            return;
        }
        header = (center_schedule_header_t*)(pkt->payload);
        header->numSlots = group[i];
        header->groupId = i + CENTER_GROUP_HEAD;

        // 为头部预留空间
        if(packetfunctions_reserveHeader(&pkt, 2) == E_FAIL) {
            openqueue_freePacketBuffer(pkt);
            openserial_root_printf("wrong:reserveHeader1");
            return;
        }
        // 填充头部
        pkt->payload[0] = CENTER_FRAME_COMMAND;
        pkt->payload[1] = CENTER_CMD_SCHEDULE;

        // 发送到Leader
        memset(&pkt->l2_nextORpreviousHop,0,sizeof(open_addr_t));
        pkt->l2_nextORpreviousHop.type = ADDR_64B;
        pkt->l2_nextORpreviousHop.addr_64b[7] = header->groupId;
        
        if(sixtop_send(pkt) != E_SUCCESS) {
            openqueue_freePacketBuffer(pkt);
            openserial_root_printf("wrong:sixtop_send");
        } else {
            root_vars.pendingAcks++;
        }
    }
    
}

/**
\brief 处理调度表确认
*/
static void root_handleScheduleAck(OpenQueueEntry_t* msg) {
    center_schedule_ack_t* ack;
    
    ack = (center_schedule_ack_t*)msg->payload;
    
    // 检查确认状态
    if(ack->status != 0) {
        // 发送错误事件到PC
        uint8_t errBuf[5];
        errBuf[0] = CENTER_FRAME_EVENT;
        errBuf[1] = CENTER_EVENT_ERROR;
        errBuf[2] = ERR_CENTER_SCHEDULE_UPDATE_FAIL;
        errBuf[3] = ack->groupId;
        errBuf[4] = ack->status;
        openserial_printData(errBuf, 5);
    }
    
    // 更新等待确认计数
    if(root_vars.pendingAcks > 0) {
        root_vars.pendingAcks--;
    }
}

static void root_handleStartAck(OpenQueueEntry_t* msg) {
    center_schedule_ack_t* ack;
    uint8_t buf[3];
    
    ack = (center_schedule_ack_t*)msg->payload;
    
    // 检查确认状态
    if(ack->status != 0) {
        return;
    }

    buf[0] = CENTER_CMD_START_ACK;
    buf[1] = ack->groupId;
    buf[2] = ack->status;
    openserial_printData(buf, 3);

    // 更新等待确认计数
    if(root_vars.pendingAcks > 0) {
        root_vars.pendingAcks--;
    }
}

/**
\brief 处理传感器数据
*/
static void root_processSensorData(OpenQueueEntry_t* msg) {
    center_aggregate_header_t* header;
    uint8_t pcBuf[2048];  // 在栈上分配缓冲区
    uint8_t pcLen = 0;
    
    openserial_root_printf("root_processSensorData");
    // 解析数据头
    header = (center_aggregate_header_t*)msg->payload;
    
    // 添加帧头
    pcBuf[pcLen++] = CENTER_FRAME_DATA;
    pcBuf[pcLen++] = CENTER_DATA_SENSOR;
    pcBuf[pcLen++] = msg->l2_nextORpreviousHop.addr_64b[7];//group Id.
    // 添加源节点ID
    // pcBuf[pcLen++] = (uint8_t)(header->srcId >> 8);
    // pcBuf[pcLen++] = (uint8_t)(header->srcId);
    
    // 添加时间戳 increment == byte0and1++
    // pcBuf[pcLen++] = (uint8_t)(header->timestamp[0]);
    // pcBuf[pcLen++] = (uint8_t)(header->timestamp[1]);
    // pcBuf[pcLen++] = (uint8_t)(header->timestamp[2]);
    // pcBuf[pcLen++] = (uint8_t)(header->timestamp[3]);
    // pcBuf[pcLen++] = (uint8_t)(header->timestamp[4]);

    // 复制传感器数据
    memcpy(&pcBuf[pcLen], 
           &msg->payload[sizeof(center_aggregate_header_t)],
           msg->length-sizeof(center_aggregate_header_t));
    pcLen += msg->length-sizeof(center_aggregate_header_t);

    // 通过串口发送到PC
    openserial_printData(pcBuf, pcLen);
}

/**
\brief 更新Leader状态
*/
static void root_updateLeaderState(uint16_t leaderId, OpenQueueEntry_t* msg) {
    uint8_t i;
    leader_monitor_t* leader = NULL;
    
    // 查找Leader记录
    for(i=0; i<CENTER_MAX_GROUPS; i++) {
        if(root_vars.leaders[i].leaderId == leaderId) {
            leader = &root_vars.leaders[i];
            break;
        }
    }
    
    if(leader == NULL) return;
    
    // 更新连接质量
    leader->linkStat.rssi = msg->l1_rssi;
    leader->linkStat.lqi = msg->l1_lqi;
    ieee154e_getAsn(leader->linkStat.lastActive);
    
    // 更新PDR,过去占比9成
    if(msg->l2_retriesLeft == TXRETRIES) {
        leader->linkStat.pdr = ((leader->linkStat.pdr * 9) + 100) / 10;
    } else {
        leader->linkStat.pdr = ((leader->linkStat.pdr * 9) + 
                               (100 * (TXRETRIES - msg->l2_retriesLeft)) / 
                               TXRETRIES) / 10;
    }
    
    // 检查状态变化
    node_state_t newState;
    if(leader->linkStat.pdr < NODE_PDR_THRESHOLD) {
        newState = NODE_STATE_UNSTABLE;
    } else {
        newState = NODE_STATE_ONLINE;
    }
    
    if(leader->state != newState) {
        leader->state = newState;
        root_notifyLeaderStateChange(leader);
    }
}

/**
\brief 通知Leader状态变化
*/
static void root_notifyLeaderStateChange(leader_monitor_t* leader) {
    uint8_t notifyBuf[10];
    uint8_t len = 0;
    
    // 准备通知数据
    notifyBuf[len++] = CENTER_FRAME_EVENT;
    notifyBuf[len++] = (uint8_t)(leader->leaderId >> 8);
    notifyBuf[len++] = (uint8_t)(leader->leaderId);
    notifyBuf[len++] = leader->state;
    notifyBuf[len++] = leader->linkStat.pdr;
    notifyBuf[len++] = leader->linkStat.rssi;
    
    // 发送到PC
    root_sendToPC(notifyBuf, len);
}

/**
\brief 检查Leader状态
*/
static void root_checkLeaderStatus(void) {
    uint8_t i;
    asn_t lastAsn;

    for(i=0; i<CENTER_MAX_GROUPS; i++) {
        leader_monitor_t* leader = &root_vars.leaders[i];
        if(leader->leaderId == 0) continue;
        
        // 检查超时
        ieee154e_orderToASNStructure(leader->linkStat.lastActive,&lastAsn);
        uint32_t timeSinceLastActive = ieee154e_asnDiff(&lastAsn);
        
        if(timeSinceLastActive > NODE_TIMEOUT_OFFLINE) {
            if(leader->state != NODE_STATE_OFFLINE) {
                leader->state = NODE_STATE_OFFLINE;
                root_notifyLeaderStateChange(leader);
            }
        } else if(timeSinceLastActive > NODE_TIMEOUT_UNSTABLE) {
            if(leader->state == NODE_STATE_ONLINE) {
                leader->state = NODE_STATE_UNSTABLE;
                root_notifyLeaderStateChange(leader);
            }
        }
    }
}

/**
\brief 处理Leader上报的状态信息
*/
static void root_handleStateReport(OpenQueueEntry_t* msg) {
    uint8_t groupId;
    uint8_t numMembers;
    uint8_t i;
    uint8_t* payload = msg->payload;
    uint8_t offset = 0;
    
    // 在栈上分配缓冲区
    //#define MAX_SERIAL_BUF_SIZE (1 + 1 + sizeof(center_state_report_t) + \
                            (sizeof(center_node_state_t) * LEADER_MAX_MEMBERS))
    uint8_t serialBuf[192];  // 1 + 1 + 8 + (8 * 16) = 138字节，取140对齐
    uint8_t len = 0;
    center_state_report_t report;
    
    // 跳过帧类型
    offset++;
    offset++;
    
    // 解析组ID和成员数量
    groupId = payload[offset++];
    numMembers = payload[offset++];
    
    // 填充报告头部
    ieee154e_getAsn(report.timestamp);
    report.groupId = groupId;
    report.numMembers = numMembers;
    
    // 发送到PC的数据包格式:
    // [CENTER_FRAME_EVENT][CENTER_EVENT_STATE_CHANGE][report][node_states...]
    serialBuf[len++] = CENTER_FRAME_EVENT;
    serialBuf[len++] = CENTER_EVENT_STATE_CHANGE;
    memcpy(&serialBuf[len], &report, sizeof(report));
    len += sizeof(report);
    
    // 复制所有节点状态
    for(i=0; i<numMembers; i++) {
        center_node_state_t* nodeState = (center_node_state_t*)&payload[offset];
        memcpy(&serialBuf[len], nodeState, sizeof(center_node_state_t));
        len += sizeof(center_node_state_t);
        offset += sizeof(center_node_state_t);
    }
    
    // 通过串口发送到PC
    openserial_printData(serialBuf, len);
}

/**
\brief 处理错误事件
*/
static void root_handleError(OpenQueueEntry_t* msg) {
    uint8_t errorType;
    uint16_t errorArg;
    uint8_t errBuf[5];  // 错误事件固定5字节
    
    // 解析错误信息
    errorType = msg->payload[2];  // 错误类型
    errorArg = (msg->payload[3] << 8) | msg->payload[4];  // 错误参数
    
    // 准备错误通知数据
    errBuf[0] = CENTER_FRAME_EVENT;
    errBuf[1] = CENTER_EVENT_ERROR;
    errBuf[2] = errorType;
    errBuf[3] = (uint8_t)(errorArg >> 8);
    errBuf[4] = (uint8_t)(errorArg);
    
    // 发送到PC
    //openserial_printData(errBuf, 5);
    
    // 根据错误类型处理
    switch(errorType) {
        case ERR_CENTER_BUFFER_FULL:
            // 缓冲区满错误
            break;
            
        case ERR_CENTER_SCHEDULE_UPDATE_FAIL:
            // 调度表更新失败
            //LOG_ERROR(COMPONENT_CENTER_SCHEDULE, errorType,(errorparameter_t)msg->payload[3],(errorparameter_t)msg->payload[4]);
            openserial_root_printf("ERR_CENTER_SCHEDULE_UPDATE_FAIL");
            break;
            
        case ERR_CENTER_NO_FREE_MEMBER_SLOT:
            // 组员槽位已满
            break;
            
        case ERR_CENTER_MEMBERS_NOT_READY:
            // 组员未就绪
            break;
        case ERR_CENTER_INVALID_MEMBER:
            openserial_root_printf("ERR_INVALID_MEMBER");
            break;
        default:
            break;
    }
}

/**
\brief 处理MAC测试命令
*/
static void root_handleMacTest(uint8_t* data, uint8_t len) {
    mac_test_pkt_t* testPkt;
    OpenQueueEntry_t* pkt;
    
    if(len < sizeof(mac_test_pkt_t)) return;
    
    testPkt = (mac_test_pkt_t*)data;
    
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) {
        // 发送错误事件到PC
        uint8_t errBuf[5];
        errBuf[0] = CENTER_FRAME_EVENT;
        errBuf[1] = CENTER_EVENT_ERROR;
        errBuf[2] = ERR_CENTER_BUFFER_FULL;
        errBuf[3] = 0;
        errBuf[4] = 0;
        openserial_printData(errBuf, 5);
        return;
    }
    
    // 为测试数据预留空间
    if(packetfunctions_reserveHeader(&pkt, len) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    // 复制测试数据
    memcpy(pkt->payload, data, len);
    //pkt->length = len;
    
    // 为头部预留空间
    if(packetfunctions_reserveHeader(&pkt, 2) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    // 填充头部
    pkt->payload[0] = CENTER_FRAME_COMMAND;
    pkt->payload[1] = CENTER_CMD_MACTEST;
    
    // 发送到目标Leader
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = testPkt->groupId;

    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }else{
        openserial_mysf_printf("pkt ready{fcf,dsn,panid,dest,src,data...}");
    }
}

/**
\brief 处理MAC测试响应
*/
static void root_handleMacTestResponse(OpenQueueEntry_t* msg) {
    mac_test_resp_t* resp;
    uint8_t respBuf[sizeof(mac_test_resp_t)];
    
    // 提取响应数据
    resp = (mac_test_resp_t*)msg->payload;
    
    // 准备发送到PC的响应
    memcpy(respBuf, resp, sizeof(mac_test_resp_t));
    
    openserial_root_printf("mactest: leader to PC");
    // 发送到PC
    openserial_printData(respBuf, sizeof(mac_test_resp_t));
} 


