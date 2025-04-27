#ifndef __CENTER_SCHEDULE_H
#define __CENTER_SCHEDULE_H

#include "opendefs.h"
#include "schedule.h"
#include "IEEE802154.h"
#include "IEEE802154E.h"
#include "scheduler.h"
#include "sixtop.h"
#include "openserial.h"

//=========================== 常量定义 =====================================

#define CENTER_MAX_GROUPS           4     // 最大组数
#define CENTER_MAX_MEMBERS          4    // 每组最大成员数
#define CENTER_MAX_SLOTS            32    // 每组最大时隙数
#define CENTER_BEACON_PERIOD        100   // 信标周期(帧)

//跳频维护常量
#define MAX_CHANNELS_PER_SLOT       4    // 每个时隙最多可用的信道数
#define MAX_SLOT_RESOURCES          32   // 每组最大时隙资源数
#define QUALITY_HISTORY_SIZE        8    // 信道质量历史记录大小
#define QUALITY_THRESHOLD           70   // 信道质量阈值(0-100)
#define SWITCH_COOLDOWN             10   // 信道切换冷却时间(帧)
#define MAX_GLOBAL_SLOTS            200   // 全局最大时隙数
#define MAX_GLOBAL_CHANNELS         50    // 全局最大信道偏移

#ifndef SCHEDULE_ROOT
#define SCHEDULE_ROOT   1
#endif

#ifndef SCHEDULE_LEADER
#define SCHEDULE_LEADER   1
#define SCHEDULE_ENABLE_MOBILE   0
#endif

#ifndef SCHEDULE_MEMBER
#define SCHEDULE_MEMBER   0
#endif

#ifndef SCHEDULE_MOBILE
#define SCHEDULE_MOBILE   0
#endif

#ifndef DEBUG_KA
#define DEBUG_KA 0
#endif

#ifndef DEBUG_ROOT_RX
#define DEBUG_ROOT_RX 1
#endif

#ifndef DEBUG_MACTEST
#define DEBUG_MACTEST 0
#endif

#ifndef DEBUG_SYNC
#define DEBUG_SYNC 0
#endif
// 组件定义
#define COMPONENT_CENTER_SCHEDULE   0x99  // 调度组件ID

//============Members============
//=========================== 定义 =========================================

#define MEMBER_STATUS_PERIOD        3000  // 状态上报周期(ms)
#define MEMBER_JOIN_TIMEOUT         5     // 加入超时时间(beacon periods)
#define MEMBER_MAX_JOIN_RETRY       3     // 最大重试次数
#define MEMBER_BEACON_TIMEOUT       3     // 信标超时时间(beacon periods)
#define MEMBER_MAX_RETRY            3     // 最大重试次数
#define MEMBER_TIMER_PERIOD         20    // 定时器周期(ms)
#define MEMBER_EXPECTED_GROUP_ID    center_vars.groupId
#define MEMBER_BROADCAST_CHANNEL    0
#define MEMBER_BROADCAST_SLOT       CENTER_SLOT_BROADCAST + MEMBER_EXPECTED_GROUP_ID
#define MEMBER_LEADER_UPLINK_SLOT   LEADER_MEMBER_UPLINK_SLOT_BASE + center_vars.myId
#define MEMBER_LEADER_UPLINK_CHANNEL   LEADER_MEMBER_UPLINK_CHANNEL_BASE //之前是 + center_vars.myId
#define MEMBER_LEADER_DOWNLINK_SLOT   LEADER_MEMBER_DOWNLINK_SLOT_BASE + center_vars.myId
#define MEMBER_LEADER_DOWNLINK_CHANNEL   LEADER_MEMBER_DOWNLINK_CHANNEL_BASE



//#define MEMBER_INDEX_IN_GROUP       0
#define ROOT_ID 0x11

#define LEADER_UPLINK_SLOT          CENTER_SLOT_UPLINK + center_vars.groupId
#define LEADER_UPLINK_CHANNEL       0
#define LEADER_DOWNLINK_SLOT        CENTER_SLOT_DOWNLINK + center_vars.groupId
#define LEADER_DOWNLINK_CHANNEL     0
#define LEADER_BROADCAST_SLOT       CENTER_SLOT_BROADCAST //之前是：+ center_vars.groupId //eg: 10+HEAD=10
#define LEADER_BORADCAST_CHANNEL    1 + center_vars.groupId //之前是：0
#define LEADER_MEMBER_UPLINK_SLOT_BASE    LEADER_BROADCAST_SLOT + 1
#define LEADER_MEMBER_UPLINK_CHANNEL_BASE LEADER_BORADCAST_CHANNEL
#define LEADER_MEMBER_DOWNLINK_SLOT_BASE   LEADER_MEMBER_UPLINK_SLOT_BASE + CENTER_MAX_MEMBERS //15
#define LEADER_MEMBER_DOWNLINK_CHANNEL_BASE LEADER_MEMBER_UPLINK_CHANNEL_BASE

enum{
    CENTER_GROUP_HEAD  =  0x00,
    CENTER_GROUP_BODY  =  0x01,
    CENTER_GROUP_ARMS  =  0x02,
    CENTER_GROUP_LEGS  =  0x03
};


// 节点角色定义
typedef enum {
    CENTER_ROLE_NONE  = 0x00,
    CENTER_ROLE_ROOT  = 0x01,
    CENTER_ROLE_LEADER = 0x02,
    CENTER_ROLE_MEMBER = 0x03
} center_role_t;

// 帧类型定义
typedef enum {
    CENTER_FRAME_BEACON = 0x00,  // 信标帧
    CENTER_FRAME_DATA   = 0x01,  // 数据帧
    CENTER_FRAME_COMMAND = 0x02,  // 命令帧
    CENTER_FRAME_ACK    = 0x03,   // 确认帧
    CENTER_FRAME_EVENT  = 0x04   // 事件帧
} center_frame_type_t;

// 命令类型定义
typedef enum {
    CENTER_CMD_SCHEDULE  = 0x01,   // 调度表更新
    CENTER_CMD_JOIN_REQ  = 0x02,   // 加入请求
    CENTER_CMD_JOIN_RSP  = 0x03,   // 加入响应
    CENTER_CMD_LEAVE     = 0x04,   // 离开通知
    CENTER_CMD_SCHED_ACK = 0x05,   // 调度表确认
    CENTER_CMD_START     = 0x06,   // 启动
    CENTER_CMD_START_ACK = 0x07,   // 启动确认
    CENTER_CMD_MACTEST   = 0x08,   // MAC测试
    
    CENTER_CMD_MACTEST_RESP = 0x09, // MAC测试响应
    CENTER_CMD_TASK_REQ  = 0x10,   // 任务请求
    CENTER_CMD_TASK_RESP = 0x11,   // 任务响应
    CENTER_CMD_TASK_PROGRESS = 0x12, // 任务进度
    CENTER_CMD_TASK_COMPLETE = 0x13 // 任务完成
} center_cmd_type_t;

// 数据类型定义
typedef enum {
    CENTER_DATA_SENSOR = 0x01,  // 传感器数据
    CENTER_DATA_STATUS = 0x02,  // 状态信息
    CENTER_DATA_EVENT  = 0x03,  // 事件通知
    CENTER_DATA_POSITION = 0x04 // 位置数据
} center_data_type_t;


typedef struct{
    uint8_t leaderId;
    slotOffset_t slotOffset;
    channelOffset_t channelOffset;

} root_leader_info_t;

// 聚合数据包头
typedef struct {
    uint8_t  frameType;    // CENTER_FRAME_AGGREGATE
    uint8_t  subType;
    //uint8_t  groupID;      // 组ID
    uint16_t numEntries;    // 包含的数据条目数
} center_aggregate_header_t;

// 单个成员数据头
typedef struct {
    uint16_t memberID;     // 成员ID
    uint16_t dataLength;   // 数据长度
} center_member_data_header_t;

// 数据包头部结构
typedef struct {
    uint8_t  type;          // 数据类型
    //uint8_t  version;       // 协议版本
    uint8_t  srcId;         // 源节点ID
    //uint16_t seqNum;        // 序列号
    //uint8_t timestamp[5];     // 时间戳
    uint8_t  length;        // 数据长度
} center_data_header_t;

// 传感器数据结构
typedef struct {
    // 基础传感器数据
    // uint16_t temperature;   // 温度
    // uint16_t humidity;      // 湿度
    // uint16_t light;         // 光照
    // uint16_t battery;       // 电池电量
    
    // 位置数据
    int16_t  x;            // X坐标(单位:mm)
    int16_t  y;            // Y坐标(单位:mm)
    int16_t  z;            // Z坐标(单位:mm)
    // uint8_t  pos_quality;  // 定位质量(0-100)
    // uint8_t  pos_type;     // 定位类型(0:相对定位, 1:绝对定位)
    // uint8_t  anchor_num;   // 参与定位的基站数量
} center_sensor_data_t;
// 传感器数据结构
typedef struct {
    // 位置数据
    int16_t pos[1];
} center_sensor_data_sim_t;
// 状态信息结构
typedef struct {
    uint8_t  rssi;         // 信号强度
    uint8_t  lqi;          // 链路质量
    uint8_t  txPower;      // 发射功率
    uint8_t  hopCount;     // 跳数
} center_status_data_t;

// 事件信息结构
typedef struct {
    uint8_t  eventType;    // 事件类型
    uint8_t  eventLevel;   // 事件等级
    uint16_t eventValue;   // 事件值
    uint32_t eventTime;    // 事件时间
} center_event_data_t;

// 时隙分配结构
typedef struct {
    uint8_t  slotOffset;     // 时隙偏移
    uint8_t  channelOffset;  // 信道偏移
    cellType_t type;        // 时隙类型(复用schedule.h中的cellType_t)
    uint8_t owner;         // 所有者ID
} center_slot_t;

// 定义root接收PC发送来的时隙资源结构
typedef struct {
    uint8_t slotOffset;                   // 时隙偏移
    cellType_t type;                      // 时隙类型
    uint8_t numChannels;                  // 可用信道数量
    uint8_t channelOffsets[MAX_CHANNELS_PER_SLOT]; // 可用的信道偏移列表
    uint8_t owner;                        // 当前使用者ID
} root_slot_resource_t;

// 信道质量记录结构
typedef struct {
    uint8_t pdr;             // 包投递率(0-100)
    int8_t  rssi;           // 信号强度
    uint8_t lqi;            // 链路质量
    uint32_t timestamp;      // 记录时间戳
} channel_quality_record_t;

// 信道资源结构
typedef struct {
    uint8_t channelOffset;           // 信道偏移
    bool    isActive;                // 是否当前在用
    uint8_t currentQuality;          // 当前质量评分(0-100)
    uint32_t lastSwitchTime;         // 上次切换时间
    channel_quality_record_t qualityHistory[QUALITY_HISTORY_SIZE];  // 质量历史记录
    uint8_t historyIndex;            // 历史记录索引
} channel_resource_t;

// 时隙资源结构
typedef struct {
    uint8_t slotOffset;                               // 时隙偏移
    uint8_t channelOffsetIndex;                       // 当前选择的channels里channel的索引（简单起见）
    cellType_t type;                                  // 时隙类型
    channel_resource_t channels[MAX_CHANNELS_PER_SLOT]; // 该时隙的所有可用信道
    uint8_t  numChannels;                             // 当前可用信道数
    uint8_t owner;                                   // 当前使用者ID
    uint8_t taskID;                                  // 该时隙用于什么任务？
} slot_resource_t;

// 组资源管理器结构
typedef struct {
    slot_resource_t slots[MAX_SLOT_RESOURCES];  // 时隙资源数组
    uint8_t numSlots;                           // 当前活跃时隙数量
    uint8_t groupId;                            // 组ID
} group_resource_manager_t;




// 定义root节点管理PC指示的所有可用时隙资源的结构
typedef struct {
    uint64_t channelBitmap;               // 信道可用位图，1表示可用，0表示不可用
    uint8_t numChannels;                  // 当前可用信道数
    uint8_t leaderBitmap;                 // 使用该时隙的leader。
} root_slot_bitmap_t;

// root节点管理的全局时隙资源表
typedef struct {
    root_slot_bitmap_t slots[MAX_GLOBAL_SLOTS];  // 时隙资源数组
    uint8_t numSlots;                            // 当前可用时隙数量
    uint8_t start;
    uint8_t end;
} root_global_resource_t;

// 组配置结构
typedef struct {
    uint8_t  groupId;        // 组ID
    uint8_t leaderId;       // 组长ID
    uint8_t  startSlot;      // 起始时隙
    uint8_t  numSlots;       // 时隙数量
    uint8_t  channelOffset;  // 基准信道偏移
    uint16_t memberMap;      // 成员位图
} center_group_t;

// 添加调度表相关结构
typedef struct {
    uint8_t  version;       // 版本号
    uint8_t  numSlots;      // 时隙数量
    uint8_t  groupId;       // 目标组ID
    uint8_t  reserved;      // 保留字节(对齐)
    // 时隙数组跟在此结构后面
} center_schedule_header_t;

// 添加调度表确认结构
typedef struct {
    uint8_t  version;       // 版本号
    uint8_t  status;        // 状态(0:成功, 非0:失败)
    uint8_t  groupId;       // 组ID
} center_schedule_ack_t;

// 添加位置数据结构
typedef struct {
    int16_t  x;           // X坐标(单位:cm)
    int16_t  y;           // Y坐标(单位:cm)
    int16_t  z;           // Z坐标(单位:cm)
    uint8_t  quality;     // 定位质量(0-100)
    uint8_t  type;        // 定位类型(0:相对定位, 1:绝对定位)
    uint8_t  anchor_num;  // 参与定位的基站数量
} center_position_data_t;

// 节点连接状态定义
typedef enum {
    NODE_STATE_OFFLINE     = 0x00,  // 离线
    NODE_STATE_ONLINE      = 0x01,  // 在线
    NODE_STATE_UNSTABLE    = 0x02,  // 不稳定
    NODE_STATE_RECONNECT   = 0x03   // 重连中
} node_state_t;

// 节点连接质量结构
typedef struct {
    uint8_t  rssi;         // 信号强度
    uint8_t  lqi;          // 链路质量
    uint8_t  pdr;          // 包接收率(0-100)
    uint8_t  retries;      // 重试次数
    uint8_t lastActive[5];   // 最后活跃时间(ASN)
    uint16_t beaconLoss;   // 信标丢失计数
    uint16_t reconnects;   // 重连次数
} node_link_stat_t;

// // 修改成员监控结构
// typedef struct {
//     uint16_t        id;           // Member ID
//     node_state_t    state;        // 状态
//     node_link_stat_t linkStat;    // 连接质量
//     uint8_t         battery;      // 电池电量
//     uint8_t         joinState;    // 加入状态(0:未加入, 1:加入中, 2:已加入)
// } member_monitor_t;

// 在事件类型定义中添加
typedef enum {
    CENTER_EVENT_STATE_CHANGE = 0x01,  // 状态变化事件
    CENTER_EVENT_ERROR       = 0x02,   // 错误事件
    CENTER_EVENT_TOPO_CHANGE = 0x03,   // 拓扑变化事件
} center_event_type_t;

// 错误事件子类型定义
typedef enum {
    ERR_CENTER_SCHEDULE_ADD_SLOT_FAIL = 0x01,  // 添加时隙失败
    ERR_CENTER_NO_FREE_MEMBER_SLOT    = 0x02,  // 没有空闲成员槽位
    ERR_CENTER_JOIN_TIMEOUT           = 0x03,  // 加入超时
    ERR_CENTER_BEACON_LOST            = 0x04,  // 信标丢失
    ERR_CENTER_JOIN_REJECT            = 0x05,  // 加入被拒绝
    ERR_CENTER_SCHEDULE_FAIL          = 0x06,  // 调度失败
    ERR_CENTER_BUFFER_FULL            = 0x07,  // 缓冲区满
    ERR_CENTER_INVALID_PARAM          = 0x08,  // 无效参数
    ERR_CENTER_SCHEDULE_UPDATE_FAIL   = 0x09,  // 调度表更新失败
    ERR_CENTER_ALLOCATION_FAIL        = 0x10,  // 调度表分配失败
    ERR_CENTER_MEMBERS_NOT_READY      = 0x11,  // 组员不全
    ERR_CENTER_INVALID_MEMBER         = 0x12,  // 目标组员不存在或离线
} center_error_code_t;

// 添加状态报告相关结构
typedef struct {
    uint8_t timestamp[5];   // 时间戳(ASN)
    uint8_t  groupId;       // 组ID
    uint8_t  numMembers;    // 成员数量
    uint8_t  reserved;      // 对齐用
} center_state_report_t;

// 节点状态报告结构
typedef struct {
    uint16_t id;           // 节点ID
    uint8_t  state;        // 状态
    uint8_t  pdr;          // PDR
    uint8_t  rssi;         // RSSI
    uint8_t  lqi;          // LQI
    uint8_t  battery;      // 电池电量
    uint8_t  joinState;    // 加入状态
} center_node_state_t;

// 添加时隙分配相关的常量
#define CENTER_SLOT_RESERVED    0     // 保留时隙
#define CENTER_SLOT_UPLINK      2     // 上行时隙起始
#define CENTER_SLOT_DOWNLINK    (CENTER_MAX_GROUPS + CENTER_SLOT_UPLINK)  // 下行时隙起始
#define CENTER_SLOT_BROADCAST   (CENTER_SLOT_DOWNLINK + CENTER_MAX_GROUPS) //10
// 添加时隙状态结构
typedef struct {
    bool            isUsed;         // 是否使用
    uint8_t         ownerId;        // 所有者ID
    cellType_t      type;           // 时隙类型(复用schedule.h中的cellType_t)
} center_slot_state_t;

// MAC测试命令
typedef enum {
    MAC_TEST_PING = 0x01,     // 测试连通性
    MAC_TEST_THROUGHPUT = 0x02 // 测试吞吐量
} mac_test_cmd_t;

// MAC测试数据包格式
typedef struct {
    uint8_t  groupId;     // 目标组ID
    uint8_t targetId;    // 目标节点ID
    uint8_t seqNum;      // 序列号
    uint8_t  payload[0];  // 测试数据
} mac_test_pkt_t;

// MAC测试响应包格式 
typedef struct {
    uint8_t  testType;    // 测试类型
    uint8_t  groupId;     // 组ID
    uint16_t nodeId;      // 节点ID
    uint16_t seqNum;      // 序列号
    uint8_t  rssi;        // 信号强度
    uint8_t  lqi;         // 链路质量
    uint8_t  result;      // 测试结果
} mac_test_resp_t;

//=========================== 模块变量 ====================================

typedef struct {
    uint8_t         role;           // 节点角色
    uint8_t         groupId;        // 所属组ID
    uint8_t         myId;           // 本节点MAC ID
    open_addr_t     myId_addr;      // 64bit
    open_addr_t     myId_addr_16;   // 16bit
    center_group_t  groups[CENTER_MAX_GROUPS];  // 组配置
    //center_slot_state_t slots[CENTER_MAX_SLOTS];  // 时隙状态
    bool            isSync;         // 同步状态
    uint16_t        dataSeqNum;     // 数据序列号
    uint32_t        lastDataTime;   // 最后数据时间
    center_position_data_t position;  // 当前位置
    bool                   isLocated; // 是否已定位
    node_state_t     state;         // 节点状态
    node_link_stat_t linkStat;      // 连接质量
    uint16_t         stateChanges;  // 状态变化次数
    slotOffset_t     ebSlot;
    channelOffset_t  ebChannel;
} center_vars_t;

extern center_vars_t center_vars;  // 全局变量声明

//=========================== 公共函数 ====================================

// 初始化函数
void center_init(center_role_t role, uint8_t subrole,uint8_t expectedGroup);
void center_init_root(void);
void center_init_leader(uint8_t subrole);
void center_init_member(uint8_t subrole,uint8_t expectedGroup);


// 调度管理函数
owerror_t center_setSchedule(uint8_t* schedule, uint8_t len);
owerror_t center_addSlot(center_slot_t* slot);
owerror_t center_addSlot_reserve(center_slot_t* slot);
owerror_t center_removeSlot(uint8_t slotOffset);

// 组管理函数
owerror_t center_joinGroup(uint8_t groupId);
owerror_t center_leaveGroup(void);
owerror_t center_configGroup(center_group_t* config);
void center_processBeacon(OpenQueueEntry_t *msg);
void center_processDesync(void);
// 数据处理函数
void center_receiveFrame(OpenQueueEntry_t* msg);
void center_sendFrame(OpenQueueEntry_t* msg);

// Root节点相关函数
void center_root_sendFrame(OpenQueueEntry_t* msg);
void center_root_receiveFrame(OpenQueueEntry_t* msg);
void root_handleCommand(uint8_t* data, uint8_t len);
void root_processDesync(void);

// Leader节点相关函数
void center_leader_sendFrame(OpenQueueEntry_t* msg);
void center_leader_receiveFrame(OpenQueueEntry_t* msg);
void center_leader_setParent(neighborRow_t* parent);
neighborRow_t* center_leader_getParent(void);
void leader_processDesync(void);




void leader_handleCommand(uint8_t* data, uint8_t len);
// Member节点相关函数
void center_member_receiveFrame(OpenQueueEntry_t* msg);
uint8_t member_get_group_id(void);
void center_member_setParent(neighborRow_t* parent);
neighborRow_t* center_member_getParent(void);
void member_processBeacon(OpenQueueEntry_t* msg);
void member_processDesync(void);
void center_member_sendFrame(OpenQueueEntry_t* msg);


// 状态查询函数
bool center_isSync(void);
uint8_t center_getRole(void);
uint8_t center_getGroupId(void);

// 添加数据相关的公共函数声明
owerror_t center_sendData(uint8_t type, uint8_t* data, uint8_t len);
void center_processData(OpenQueueEntry_t* msg);


void center_handleCommand(uint8_t* data, uint8_t len);

// 添加状态监控相关的常量
#define NODE_TIMEOUT_UNSTABLE   3    // 不稳定阈值(beacon periods * LEADER_TIMER_PERIOD)
#define NODE_TIMEOUT_OFFLINE    10   // 离线阈值(beacon periods * LEADER_TIMER_PERIOD)
#define NODE_PDR_THRESHOLD      70   // PDR阈值(%)
#define NODE_MAX_RETRIES        3    // 最大重试次数

static const root_leader_info_t ROOT_LEADER_LINKS[] = {
    {.leaderId = 0x01, .slotOffset = 1, .channelOffset = 1},  // 头颈组长
    {.leaderId = 0x02, .slotOffset = 2, .channelOffset = 2},  // 躯干组长
    {.leaderId = 0x03, .slotOffset = 3, .channelOffset = 3},  // 上肢组长
    {.leaderId = 0x04, .slotOffset = 4, .channelOffset = 4}   // 下肢组长
};

#endif /* __CENTER_SCHEDULE_H */ 