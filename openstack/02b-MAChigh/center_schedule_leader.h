#ifndef __CENTER_SCHEDULE_LEADER_H
#define __CENTER_SCHEDULE_LEADER_H

#include "center_schedule.h"
#include "openqueue.h"
#include "packetfunctions.h"
#include "idmanager.h"
#include "scheduler.h"
#include "opentimers.h"
#include "IEEE802154.h"

//=========================== 定义 =========================================

#define LEADER_MIN_MEMBERS     0  // 最小固定组员数
#define LEADER_MAX_MEMBERS      CENTER_MAX_MEMBERS  // 最大组员数
#define LEADER_BEACON_PERIOD    10  // 信标发送周期(帧)
#define LEADER_TIMER_PERIOD     2000    // 定时器周期(ms)
#define MEMBER_JOIN_STATE_NONE     0  // 未加入
#define MEMBER_JOIN_STATE_JOINING  1  // 加入中
#define MEMBER_JOIN_STATE_JOINED   2  // 已加入

// 添加Member状态监控相关的结构
typedef struct {
    uint8_t         id;           // Member ID
    node_state_t    state;        // 状态
    node_link_stat_t linkStat;    // 连接质量
    uint8_t         battery;      // 电池电量
    uint8_t         joinState;    // 加入状态
    uint8_t         priority;     // 优先级

    bool            isTaskActive; // 是否正在执行任务
    //task_struct*    tasks[MAX_TASKS_PER_MEMBER]//该member正在执行的任务集合  
} member_monitor_t;

//=========================== 变量 =========================================
// 添加缓存相关定义
#define MAX_CACHED_DATA_SIZE   128  // 每个成员缓存的最大数据量
#define COLLECTION_TIMEOUT     10000 // 数据收集超时时间(ms)
typedef struct {
    uint8_t  data[MAX_CACHED_DATA_SIZE];
    uint16_t length;
    bool     received;
} member_data_cache_t;



typedef struct {
    bool             isActive;        // 是否激活
    bool             ebEnabled;       // 直接关联EB包的产生。
    uint8_t          freeMembers;     // 没有执行工作的memebr
    uint8_t          numMembers;      // 当前组员数
    member_monitor_t members[LEADER_MAX_MEMBERS];  // 组员监控
    uint32_t         membersActive;   //位图，legacy。
    uint8_t          beaconSeqNum;    // 信标序号
    uint8_t          scheduleVersion; // 调度表版本
    opentimers_id_t  timerId;        // 定时器ID
    neighborRow_t    *parent;        //用于KA
    group_resource_manager_t resourceManager;
} leader_vars_t;


bool isOkToSendEB(void);
#endif /* __CENTER_SCHEDULE_LEADER_H */ 