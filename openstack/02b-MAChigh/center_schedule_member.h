#ifndef __CENTER_SCHEDULE_MEMBER_H
#define __CENTER_SCHEDULE_MEMBER_H

#include "openqueue.h"
#include "packetfunctions.h"
#include "idmanager.h"
#include "scheduler.h"
#include "opentimers.h"
#include "IEEE802154.h"
#include "IEEE802154E.h"
#include "openrandom.h"
#include "center_schedule.h"
#include "center_schedule_tasks.h"


// 组员状态定义
typedef enum {
    MEMBER_STATE_INIT = 0,     // 初始状态
    MEMBER_STATE_SCANNING,     // 扫描信标
    MEMBER_STATE_JOINING,      // 正在加入
    MEMBER_STATE_ACTIVE,       // 正常工作
    MEMBER_STATE_SCHEDULED,    // 调度完成
    MEMBER_STATE_LOST          // 失去连接
} member_state_t;

// 添加新的命令响应定义
typedef enum {
    JOIN_RSP_SUCCESS = 0x00,
    JOIN_RSP_FULL    = 0x01,
    JOIN_RSP_REJECT  = 0x02
} join_response_t;

//=========================== 变量 =========================================

typedef struct {
    member_state_t  state;          // 当前状态
    uint16_t        leaderId;       // 组长MAC ID
    uint8_t         groupId;        // 组ID
    uint8_t         lastBeaconSeq;  // 最后收到的信标序号
    uint8_t         joinRetries;    // 加入重试次数
    opentimers_id_t statusTimer;    // 状态上报定时器
    uint8_t         lastBeaconAsn[5];  // 最后收到信标的ASN
    uint8_t         retryCount;     // 重试计数
    uint8_t         batteryLevel;   // 电池电量
    bool            isJoining;      // 是否正在加入
    uint8_t         scheduleVersion; // 调度表版本号
    neighborRow_t    *parent;   //用于KA
} member_vars_t;

//=========================== 原型 =========================================


#endif /* __CENTER_SCHEDULE_MEMBER_H */ 