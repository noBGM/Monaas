#ifndef __CENTER_SCHEDULE_ROOT_H
#define __CENTER_SCHEDULE_ROOT_H

#include "center_schedule.h"
#include "openserial.h"
#include "openqueue.h"
#include "packetfunctions.h"
#include "idmanager.h"
//#include "center_schedule_tasks.h"

//=========================== 定义 =========================================

// PC命令类型
typedef enum {
    ROOT_CMD_SCHEDULE = 0x01,   // 调度表更新
    ROOT_CMD_CONTROL  = 0x02,   // 控制命令
    ROOT_CMD_QUERY    = 0x03,   // 状态查询
    ROOT_CMD_MACTEST  = 0x04,   // MAC检测
    ROOT_CMD_TASK     = 0X05,   // 任务模块测试
    ROOT_CMD_TASK_CLEAR = 0X06  // 清除所有任务及其资源
} root_cmd_type_t;

// 添加Leader状态监控相关的结构
typedef struct {
    uint16_t        leaderId;      // Leader ID
    node_state_t    state;         // 状态
    node_link_stat_t linkStat;     // 连接质量
    uint8_t         numMembers;    // 组内成员数
    uint8_t         groupId;       // 组ID
    uint32_t        lastReport;    // 最后上报时间
    group_resource_manager_t resource; //组资源，初始化的时候需要考虑每个小组最基本的资源占用
} leader_monitor_t;

// 添加状态检查周期常量
#define ROOT_CHECK_PERIOD    500     // 状态检查周期(ms)

//=========================== 变量 =========================================

typedef struct {
    bool             isActive;       // 是否激活
    uint16_t         seqNum;        // 命令序号
    uint8_t          pendingAcks;   // 等待确认数
    leader_monitor_t leaders[CENTER_MAX_GROUPS];  // Leader状态监控
    root_global_resource_t slotResource;

    opentimers_id_t  statusTimer;   // 状态检查定时器
} root_vars_t;

// group_resource_manager_t groupResourceManagers[CENTER_MAX_GROUPS];


#endif /* __CENTER_SCHEDULE_ROOT_H */ 