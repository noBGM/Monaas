/**
* Task Scheduling System Header File
* Defines task management functionality for root, leader, and member roles
*/

#ifndef __CENTER_SCHEDULE_TASKS_H
#define __CENTER_SCHEDULE_TASKS_H

#include "opendefs.h"
#include "openqueue.h"
#include "center_schedule.h"
#include "center_schedule_root.h"
#include "center_schedule_leader.h"

//=========================== Constants Definition =======================================

// Debug switch
#define DEBUG_DETAIL 1   // Set to 1 to enable detailed debug output, 0 to disable

#define MAX_LEADERS           CENTER_MAX_GROUPS  // Maximum number of leaders
#define MAX_TASKS_PER_LEADER  5 // Maximum tasks supported by each leader
#define MAX_QUEUED_TASKS      5  // Maximum queued tasks per leader
#define MAX_MEMBERS_PER_TASK  10 // Maximum members assigned to each task
#define MAX_TASKS_PER_MEMBER  5  // Maximum tasks executed by each member
#define MAX_SLOTS             50 // Maximum number of slots
#define MAX_SLOTS_PER_TASK    20 // Maximum slots allocated per task

#define MEMBER_TASKS_REPORT_BATCH 1 // Number of tasks reported by a member in each batch


//=========================== Type Definition =======================================
#define TASK_ID_KITCHEN_MONITOR      0
#define TASK_ID_KITCHEN_FIRE_DETECT  1
#define TASK_ID_PATROL_REGULAR       2
#define TASK_ID_PATROL_INTENSIVE     3
#define PREDEFINED_TASKS_COUNT       4


// 任务属性，用于时隙分配
typedef enum {
    CPU_INTENSIVE = 0x01,
    IO_INTENSIVE = 0x02,
} task_attribute;

// 任务类别，用于组长选取，因为不同组长管理不同的区域
typedef enum {
    KITCHEN = 0x01, // IO密集型，因为只需要存在事件的时候报告即可
    PATROL = 0x02,  // CPU密集型，因为需要实时报告巡逻过程
} task_class;

// 任务约束定义
typedef struct {
    union {
        struct { // 用于CPU密集型任务，一般是传感器收集数据
            uint8_t frequency; // 任务执行频率
            uint8_t duration;  // 任务执行时长
        } cpu;
        struct { // 用于IO密集型任务，一般是交互型任务
            uint8_t target;    // 目标
            uint8_t threshold; // 阈值
        } io;
    } data;
} task_constraint;

// 任务类型定义
typedef struct {
    task_attribute attr;
    task_class class;
} task_type;


// 资源描述结构体
typedef struct {
    uint8_t numSlots;    // 所需时隙数量
    uint8_t numMembers;  // 所需人力资源数量
} resource_desc_t;

// 任务结构体定义
typedef struct {
    uint8_t taskID; //需要经过3级转换。是对父级节点tasks数组的索引。
    task_type type;
    task_constraint constraint;
    uint8_t memberCount; //任务需要的组员数
    uint8_t resCount;//任务需要使用的时隙资源数，方便资源释放。

    uint8_t leaderID; // 负责该任务的leader
    uint8_t progress; // 当前任务进度
    bool active;      // 是否激活
    uint8_t compatibleMask;//任务支持与其并行的任务掩码
    uint8_t indexTbl; //task 到 leader_tasks_vars.activeTasks[]或member_tasks_vars.activeTasks[]的索引的映射。
    uint8_t virID; //提供给下一级的虚拟taskID。
    slot_resource_t* resource[MAX_SLOTS_PER_TASK]; //任务使用的资源。
} task_struct;

/**
 * 实现基于FIFO排序的任务列表
 * 用于管理根节点上的任务队列
 */
typedef struct {
    task_struct *tasks[MAX_QUEUED_TASKS];  // 任务数组
    uint8_t head;                         // 队列头指针
    uint8_t tail;                         // 队列尾指针
    uint8_t size;                         // 当前队列大小
    uint8_t capacity;                     // 队列最大容量
} task_queue_t;


// 根节点任务管理结构体
typedef struct {
    struct {
        uint8_t taskCount;             // 组长正在负责的任务数量
        uint8_t queuedTaskCount;       // 根节点为组长排队的任务数量
        uint8_t completedTaskCount;    // 组长已完成的任务数量
        uint8_t failedTaskCount;       // 组长执行失败的任务数量
        task_struct *tasks[MAX_TASKS_PER_LEADER]; //正在执行的任务指针。
        uint8_t max_active;            // 最多同时执行的任务数，默认MAX_TASKS_PER_LEADER，可减小。
        task_class class;              // 每个leader只支持1种特定class场景下的任务。因为leader的位置是几乎固定的。
        leader_monitor_t *leader;      // 组长监控信息
    } leaders[MAX_LEADERS];            // 索引就是leaderID。
    uint8_t activeTaskCount;           // 系统中正在执行的总任务数量
    uint8_t queuedTaskCount;           // 系统中正在排队的总任务数量
    uint8_t max_queued;                 
} root_tasks_t;



typedef enum {
    WORKING = 0x01, 
    RECRUITING = 0x02,
    FREE = 0X03
} taskState;

// leader全局变量类型
typedef struct {
    struct {
        task_struct* task;                                 // 指向task_struct的指针
        member_monitor_t *members[MAX_MEMBERS_PER_TASK];   // 任务的人力资源
        uint8_t memberCount;                               // 任务人力资源数量
        bool ebEnabled;                                    // 是否使能EB包发送
        taskState state;                                   // 1working/2eb/3empty.
    } activeTasks[MAX_TASKS_PER_LEADER];                   // 正在执行的任务
    uint8_t activeTaskCount;                               // 正在执行的任务数量
} leader_tasks_t;

// member全局变量类型
typedef struct {
    struct {
        task_struct* task;                                 // 指向task_struct的指针
        center_slot_t slotResources[MAX_SLOTS_PER_TASK];   // 任务的时隙资源，方便资源释放。
        uint8_t slotCount;                                 // 任务的时隙资源数量
        taskState state;                                   // 1working/2eb/3empty.
    } activeTasks[MAX_TASKS_PER_MEMBER];                   // 正在执行的任务
    uint8_t activeTaskCount;                               // 正在执行的任务数量
} member_tasks_t;


//=========================== Function Declaration =======================================

/**
 * Root series function implementation
 */
void root_initTaskHandler(void);
uint8_t root_taskChooseLeader(task_class class, uint8_t taskID);
resource_desc_t root_calcTaskResource(uint8_t leader, task_attribute attr, task_constraint* constraint);
bool root_getResourceSendTask(uint8_t leader, task_struct* task, resource_desc_t resourceDesc, root_slot_resource_t *resource);
bool root_assignTask(uint8_t leader, task_struct* task, root_slot_resource_t *resource, resource_desc_t resourceDesc);
void root_handleTask(task_struct* task);
uint8_t task_findFirstInactive(task_struct *tasks[], uint8_t maxTasks);
void root_handleTaskProgress(OpenQueueEntry_t* msg);
void root_handleTaskResponse(OpenQueueEntry_t* msg);

/**
 * Leader series function implementation
 */
void leader_initTaskHandler(void);
void leader_handleTask(OpenQueueEntry_t* msg);
void leader_handleTaskProgress(OpenQueueEntry_t* msg);
bool leader_slotAllocation(member_monitor_t *membersChosen[], uint8_t memberFound, task_struct *task);
bool leader_assignTaskPrepare(task_struct *task);
/**
 * Member series function implementation
 */
void member_initTaskHandler(void);
void member_handleTask(OpenQueueEntry_t* msg);
void member_notifTaskProgress(task_struct* task);
void member_sendProgress(void);
/**
 * Helper functions
 */
void task_execute(void);
void task_mayStart(void);
task_struct* task_findFreeTaskContainer(task_struct *tasks, uint8_t maxTasks);
task_struct* task_getGlobalTask();
task_struct* task_getPredefinedTask(uint8_t index);
uint8_t task_getFreeTaskList();
void task_queue_init(task_queue_t* queue);
bool task_queue_isEmpty(task_queue_t* queue);
bool task_queue_enqueue(task_queue_t* queue, task_struct* task);
bool task_queue_dequeue(task_queue_t* queue, task_struct** task);
bool task_queue_peek(task_queue_t* queue, task_struct** task);
bool task_queue_loop(task_queue_t* queue, task_struct** task);
uint8_t task_queue_size(task_queue_t* queue);
void task_queue_clear(task_queue_t* queue);
slot_resource_t *task_findAvailSlots(slot_resource_t *slots, uint8_t max);
uint8_t task_findFirstInactive(task_struct *tasks[], uint8_t maxTasks);
void task_freeTaskContainer(task_struct *task);
void task_rslotToSlot(slot_resource_t *slot, root_slot_resource_t *rslot,task_struct *task);
void task_slotToCslot(slot_resource_t *slot, center_slot_t *cslot);
void task_mayStart(void);
task_struct* task_findTaskByID(uint8_t taskID);
task_struct* task_getGlobalTask();
task_struct* task_getPredefinedTask(uint8_t index);
void task_freeAll(void);
void task_showAll(void);



#endif