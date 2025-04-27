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
#include "center_schedule_member.h"


static void member_timer_cb(opentimers_id_t id);
static void member_task_cb(void);
static void member_sendStatus(void);
static void member_sendJoinRequest(void);
static uint32_t member_getTimeSinceLastBeacon(void);
static void member_handleJoinResponse(OpenQueueEntry_t* msg);
static void member_handleSchedule(OpenQueueEntry_t* msg);
static void member_checkConnection(void);
static void member_enterLostState(void);
static void member_clearSchedule(void);
static void member_notifyError(uint8_t errorType, uint16_t arg);
static void member_collectSensorData(center_sensor_data_t* sensorData);
static void member_updatePosition(void);
static owerror_t member_sendSensorData(void);

member_vars_t member_vars;

/**
\brief 初始化组员节点
*/
void center_init_member(uint8_t subrole, uint8_t expectedGroup) {
    center_slot_t slot;
    open_addr_t neighbor;
    // 重置变量
    memset(&member_vars, 0, sizeof(member_vars_t));
    
    // 设置初始状态
    member_vars.state = MEMBER_STATE_INIT;
    member_vars.groupId = expectedGroup;
    center_vars.role = CENTER_ROLE_MEMBER;
    center_vars.myId = subrole; //MEMBER_INDEX_IN_GROUP;//idmanager_getMyID(ADDR_64B)->addr_64b[7];
    center_vars.groupId = member_vars.groupId;
    memset(center_vars.myId_addr.addr_64b, 0, sizeof(center_vars.myId_addr.addr_64b));
    center_vars.myId_addr.addr_64b[7] = center_vars.myId;
    center_vars.myId_addr_16.addr_16b[0] = 0;
    center_vars.myId_addr_16.addr_16b[1] = center_vars.myId_addr.addr_64b[7];
    
    center_vars.myId_addr.type = ADDR_64B;
    center_vars.myId_addr_16.type = ADDR_16B;
    idmanager_setMyID(&center_vars.myId_addr);
    idmanager_setMyID(&center_vars.myId_addr_16);

    // 创建状态上报定时器
    member_vars.statusTimer = opentimers_create(TIMER_GENERAL_PURPOSE, TASKPRIO_COAP);
    opentimers_scheduleIn(
        member_vars.statusTimer,
        MEMBER_STATUS_PERIOD,
        TIME_MS,
        TIMER_PERIODIC,
        member_task_cb
    );
    // 配置组内广播时隙(Leader->Member)
    slot.slotOffset = MEMBER_BROADCAST_SLOT;
    slot.channelOffset = MEMBER_BROADCAST_CHANNEL;
    slot.type = CELLTYPE_RX;  // Leader接收

    memset(&neighbor,0,sizeof(neighbor));
    neighbor.type = ADDR_64B;
    neighbor.addr_64b[7] = expectedGroup;

    if(schedule_addActiveSlot(
        slot.slotOffset,
        slot.type,
        FALSE,          // 非共享
        FALSE,          
        slot.channelOffset,
        &neighbor
    ) != E_SUCCESS) {
        // 错误处理
        return;
    }
    // 配置组内单播时隙(Member->Leader)
    slot.slotOffset = MEMBER_LEADER_UPLINK_SLOT;
    slot.channelOffset = MEMBER_LEADER_UPLINK_CHANNEL;
    slot.type = CELLTYPE_TX;  // Leader接收
    if(schedule_addActiveSlot(
        slot.slotOffset,
        slot.type,
        FALSE,          // 非共享
        FALSE,          
        slot.channelOffset,
        &neighbor
    ) != E_SUCCESS) {
        // 错误处理
        return;
    }    
    // 配置组内单播时隙(Leader->Member)
    slot.slotOffset = MEMBER_LEADER_DOWNLINK_SLOT;
    slot.channelOffset = MEMBER_LEADER_DOWNLINK_CHANNEL;
    slot.type = CELLTYPE_RX;  // Leader发送
    if(schedule_addActiveSlot(
        slot.slotOffset,
        slot.type,
        FALSE,          // 非共享
        FALSE,          
        slot.channelOffset,
        &neighbor
    ) != E_SUCCESS) {
        // 错误处理
        return;
    }    
    // 启动扫描
    member_vars.state = MEMBER_STATE_SCANNING;
    //scheduler_push_task(member_task_cb, TASKPRIO_COAP);

    member_initTaskHandler();
}

/**
\brief 处理接收到的数据帧
*/
void center_member_receiveFrame(OpenQueueEntry_t* msg) {
    uint8_t frameType;
    uint8_t cmdType;
    
    // 提取帧类型
    frameType = msg->payload[0];
    packetfunctions_tossHeader(&msg,1);
    switch(frameType) {
        case CENTER_FRAME_BEACON:
            member_processBeacon(msg);//不会执行此分支，此处代码未来会移除。
            break;
            
        case CENTER_FRAME_COMMAND:
            cmdType = msg->payload[0];
            packetfunctions_tossHeader(&msg,1);
            switch(cmdType) {
                case CENTER_CMD_SCHEDULE:
                    member_handleSchedule(msg);
                    break;
                    
                case CENTER_CMD_JOIN_RSP:
                    // TODO: 处理加入响应
                    break;
                    
                case CENTER_CMD_START:
                    // 处理启动命令
                    break;
                    
                case CENTER_CMD_MACTEST:
                    {
                        mac_test_pkt_t* testPkt = (mac_test_pkt_t*)&msg->payload[0];
                        mac_test_resp_t resp;
                        OpenQueueEntry_t* pkt;
                        
                        // 准备响应数据
                        resp.groupId = center_vars.groupId;
                        resp.nodeId = center_vars.myId;
                        resp.seqNum = testPkt->seqNum;
                        resp.rssi = msg->l1_rssi;
                        resp.lqi = msg->l1_lqi;
                        resp.result = 0;  // 成功
                        
                        // 分配响应包
                        pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
                        if(pkt == NULL) return;
                        
                        // 为响应数据预留空间
                        if(packetfunctions_reserveHeader(&pkt, sizeof(mac_test_resp_t)) == E_FAIL) {
                            openqueue_freePacketBuffer(pkt);
                            return;
                        }
                        
                        // 填充响应数据
                        memcpy(pkt->payload, &resp, sizeof(mac_test_resp_t));
                        //pkt->length = sizeof(mac_test_resp_t);
                        
                        // 为头部预留空间
                        if(packetfunctions_reserveHeader(&pkt, 2) == E_FAIL) {
                            openqueue_freePacketBuffer(pkt);
                            return;
                        }
                        
                        // 填充头部
                        pkt->payload[0] = CENTER_FRAME_COMMAND;
                        pkt->payload[1] = CENTER_CMD_MACTEST_RESP;
                        
                        // 发送到Leader
                        pkt->l2_nextORpreviousHop.type = ADDR_64B;
                        pkt->l2_nextORpreviousHop.addr_64b[7] = member_vars.groupId;
                        
                        if(sixtop_send(pkt) != E_SUCCESS) {
                            openqueue_freePacketBuffer(pkt);
                        }
                    }
                    break;
                case CENTER_CMD_TASK_REQ:
                    member_handleTask(msg);
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
}

uint8_t member_get_group_id(void){
    return member_vars.groupId;
}

void center_member_setParent(neighborRow_t* parent){
    openserial_member_printf("center_member_setParent");
    member_vars.parent = parent;
    return;
}
neighborRow_t* center_member_getParent(){
    return member_vars.parent;
}

//=========================== 私有函数 =====================================

/**
\brief 定时器回调函数
*/
static void member_timer_cb(opentimers_id_t id) {
    scheduler_push_task(member_task_cb, TASKPRIO_COAP);
}

/**
\brief 组员任务回调函数
*/
static void member_task_cb(void) {
    // 检查连接状态
    member_checkConnection();
    
    // 根据状态执行相应操作
    switch(member_vars.state) {
        case MEMBER_STATE_SCANNING:
            // 检查是否超时
            // if(member_getTimeSinceLastBeacon() > MEMBER_JOIN_TIMEOUT) {
            //     if(++member_vars.retryCount >= MEMBER_MAX_RETRY) {
            //         member_enterLostState();
            //     }
            // }
            break;
            
        case MEMBER_STATE_SCHEDULED:
            // 发送状态信息
            //member_sendStatus();
            // 发送传感器数据
            //member_sendSensorData();
            
            member_sendProgress();
            break;
            
        case MEMBER_STATE_LOST:
            // 尝试重新加入
            member_vars.state = MEMBER_STATE_SCANNING;
            break;
            
        default:
            break;
    }
}

/**
\brief 发送状态信息
*/
static void member_sendStatus(void) {
    OpenQueueEntry_t* pkt;
    
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) return;
    
    // 为状态数据预留空间
    if(packetfunctions_reserveHeader(&pkt, 1) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    // 填充状态数据
    pkt->payload[0] = member_vars.batteryLevel;
    //pkt->length = 1;
    
    // 为头部预留空间
    if(packetfunctions_reserveHeader(&pkt, 2) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    // 填充头部
    pkt->payload[0] = CENTER_FRAME_DATA;
    pkt->payload[1] = CENTER_DATA_STATUS;
    
    // 发送到组长
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = member_vars.groupId;
    
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }
}

/**
\brief 发送加入请求
*/
static void member_sendJoinRequest(void) {
    OpenQueueEntry_t* pkt;
    
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) return;
    
    // 为加入请求数据预留空间
    if(packetfunctions_reserveHeader(&pkt, 2) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    // 填充加入请求数据
    pkt->payload[0] = member_vars.groupId;
    pkt->payload[1] = center_vars.myId;
    //pkt->length = 2;
    
    // 为头部预留空间
    if(packetfunctions_reserveHeader(&pkt, 2) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    // 填充头部
    pkt->payload[0] = CENTER_FRAME_COMMAND;
    pkt->payload[1] = CENTER_CMD_JOIN_REQ;
    
    // 发送到组长
    memset(&pkt->l2_nextORpreviousHop,0,sizeof(open_addr_t));
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = member_vars.groupId;
    
    openserial_member_printf("member_sendJoinRequest");
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }
}

/**
\brief 处理信标帧
*/
void member_processBeacon(OpenQueueEntry_t* msg) {
    // uint8_t beaconSeq;
    uint8_t groupId;
    OpenQueueEntry_t* pkt;
    
    // // 提取信标信息
    // beaconSeq = msg->payload[1];
    groupId = msg->l2_nextORpreviousHop.addr_64b[7];
    
    // // 更新最后收到信标时间
    // ieee154e_getAsn(member_vars.lastBeaconAsn);
    
    // 检查状态
    if(member_vars.state == MEMBER_STATE_SCANNING & member_vars.groupId == groupId) {
        // 记录组长信息
        member_vars.leaderId = groupId;
        // 发送加入请求
        // member_sendJoinRequest();
        //member_vars.state = MEMBER_STATE_JOINING;
        member_vars.state = MEMBER_STATE_ACTIVE;
        openserial_member_printf("MEMBER_STATE_ACTIVE");
    }
    member_sendJoinRequest();

    // 更新信标序号
    //member_vars.lastBeaconSeq = beaconSeq;
}


void member_processDesync(void){
    member_vars.state = MEMBER_STATE_SCANNING;
}

/**
\brief 获取自上次收到信标以来的时间
*/
static uint32_t member_getTimeSinceLastBeacon(void) {
    asn_t lastAsn;
    ieee154e_orderToASNStructure(member_vars.lastBeaconAsn,&lastAsn);
    return ieee154e_asnDiff(&lastAsn);
}

/**
\brief 处理加入响应
*/
static void member_handleJoinResponse(OpenQueueEntry_t* msg) {
    join_response_t response;
    
    if(member_vars.state != MEMBER_STATE_JOINING) {
        return;
    }
    
    response = (join_response_t)msg->payload[2];
    
    switch(response) {
        case JOIN_RSP_SUCCESS:
            // 加入成功
            member_vars.state = MEMBER_STATE_ACTIVE;
            member_vars.isJoining = FALSE;
            member_vars.retryCount = 0;
            // 启动状态上报定时器
            opentimers_scheduleIn(
                member_vars.statusTimer,
                MEMBER_STATUS_PERIOD,
                TIME_MS,
                TIMER_PERIODIC,
                member_timer_cb
            );
            break;
            
        case JOIN_RSP_FULL:
        case JOIN_RSP_REJECT:
            // 加入失败,重试或放弃
            if(++member_vars.retryCount >= MEMBER_MAX_RETRY) {
                member_enterLostState();
            } else {
                member_vars.state = MEMBER_STATE_SCANNING;
            }
            break;
            
        default:
            break;
    }
}

/**
\brief 处理调度表更新
*/
static void member_handleSchedule(OpenQueueEntry_t* msg) {
    center_schedule_header_t* header;
    uint8_t* slots;
    uint8_t i;
    bool success = TRUE;

    if(member_vars.state == MEMBER_STATE_ACTIVE)
        member_vars.state = MEMBER_STATE_SCHEDULED;
    else{
        openserial_member_printf("wrong state: member_vars.state = %d", member_vars.state);
        return;
    }

    // 解析头部
    header = (center_schedule_header_t*)&msg->payload[0];
    slots = (uint8_t*)&msg->payload[sizeof(center_schedule_header_t)];
    
    //openserial_member_printf("got here");
    // 检查组ID
    if(header->groupId != member_vars.groupId) {
        openserial_member_printf("wrong group id: %d", header->groupId);
        return;
    }
    openserial_member_printf("got schedule from group %d", header->groupId);
    // 清除旧的调度表
    member_clearSchedule();
    
    // 更新本地调度表
    for(i=0; i<header->numSlots; i++) {
        center_slot_t slot;
        slot.slotOffset = slots[i*4];
        slot.channelOffset = slots[i*4 + 1];
        slot.type = slots[i*4 + 2];
        slot.owner = slots[i*4 + 3];
        
        // 只添加属于自己的时隙
        if(slot.owner == center_vars.myId) {
            slot.owner = member_vars.groupId;
            if(center_addSlot(&slot) != E_SUCCESS) {
                success = FALSE;
                openserial_member_printf("add schedule wrong: [%d,%d,%d,%d]",slot.slotOffset, slot.channelOffset,slot.type,slot.owner);
                // 通知Leader节点错误
                //member_notifyError(ERR_CENTER_SCHEDULE_ADD_SLOT_FAIL, slot.slotOffset);
                return;
            }else{
                openserial_member_printf("add schedule: [%d,%d,%d,%d]",slot.slotOffset, slot.channelOffset,slot.type,slot.owner);
            }
        }
    }

    
    // if(success) {
    //     // 更新状态
    //     member_vars.scheduleVersion = header->version;
        
    //     // 如果是SCANNING状态,切换到ACTIVE
    //     if(member_vars.state == MEMBER_STATE_SCANNING) {
    //         member_vars.state = MEMBER_STATE_ACTIVE;
            
    //         // 启动状态上报定时器
    //         opentimers_scheduleIn(
    //             member_vars.statusTimer,
    //             MEMBER_STATUS_PERIOD,
    //             TIME_MS,
    //             TIMER_PERIODIC,
    //             member_timer_cb
    //         );
    //     }
    // } else {
    //     // 调度表更新失败,重新扫描
    //     member_vars.state = MEMBER_STATE_SCANNING;
    //     opentimers_cancel(member_vars.statusTimer);
    // }
}

/**
\brief 检查连接状态
*/
static void member_checkConnection(void) {
    if(member_vars.state == MEMBER_STATE_ACTIVE || member_vars.state == MEMBER_STATE_SCHEDULED) {
        // 检查是否失去连接
        if(!ieee154e_isSynch()) {
            member_notifyError(ERR_CENTER_BEACON_LOST, member_getTimeSinceLastBeacon());
            member_enterLostState();
        }
    }
}

/**
\brief 进入失联状态
*/
static void member_enterLostState(void) {
    member_vars.state = MEMBER_STATE_LOST;
    member_vars.isJoining = FALSE;
    
    // 停止定时器
    opentimers_cancel(member_vars.statusTimer);
    
    // 清除调度表
    member_clearSchedule();
    
    // 触发重新加入
    member_vars.retryCount = 0;
    member_vars.state = MEMBER_STATE_SCANNING;
}

/**
\brief 清除本地调度表
*/
static void member_clearSchedule(void) {
    openserial_member_printf("clear original schedule");
    schedule_removeAllMoveableCells();
}

/**
\brief 更新电池电量
*/
static void member_updateBatteryLevel(void) {
    // TODO: 实际项目中需要从硬件读取电池电量
    // 这里使用模拟值
    member_vars.batteryLevel = 0x80;
}

/**
\brief 错误处理函数
*/
static void member_notifyError(uint8_t errorType, uint16_t arg) {
    OpenQueueEntry_t* pkt;
    uint8_t len = 0;
    
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) return;
    
    // 准备错误通知数据包
    pkt->payload[len++] = CENTER_FRAME_EVENT;
    pkt->payload[len++] = CENTER_EVENT_ERROR;  // 错误事件
    pkt->payload[len++] = errorType;
    pkt->payload[len++] = (uint8_t)(arg >> 8);
    pkt->payload[len++] = (uint8_t)(arg);
    //pkt->length = len;
    
    // 发送到Leader
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = member_vars.groupId;
    
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }
}

/**
\brief 采集传感器数据
*/
static void member_collectSensorData(center_sensor_data_t* sensorData) {
    // 采集基础传感器数据
    // sensorData->temperature = 0; // TODO: 实际项目中从温度传感器读取
    // sensorData->humidity = 0;    // TODO: 实际项目中从湿度传感器读取
    // sensorData->light = 0;       // TODO: 实际项目中从光照传感器读取
    // sensorData->battery = member_vars.batteryLevel;
    
    // 采集位置数据
    // TODO: 实际项目中应该调用定位API
    // 这里模拟位置数据
    sensorData->x = openrandom_get16b();
    sensorData->y = openrandom_get16b();
    sensorData->z = openrandom_get16b();
    // sensorData->pos_quality = 85;  // 85%的定位质量
    // sensorData->pos_type = 0;      // 相对定位
    // sensorData->anchor_num = 4;    // 4个基站参与定位
}

/**
\brief 发送传感器数据
*/
static owerror_t member_sendSensorData(void) {
    OpenQueueEntry_t* pkt;
    center_sensor_data_t sensorData;
    
    openserial_member_printf("member_sendSensorData");
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) return E_FAIL;
    
    // 采集传感器数据
    member_collectSensorData(&sensorData);
    
    // 为传感器数据预留空间
    if(packetfunctions_reserveHeader(&pkt, sizeof(center_sensor_data_t)) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return E_FAIL;
    }
    
    // 填充传感器数据
    memcpy(pkt->payload, &sensorData, sizeof(center_sensor_data_t));
    //pkt->length = sizeof(center_sensor_data_t);
    
    // 为头部预留空间
    if(packetfunctions_reserveHeader(&pkt, sizeof(center_data_header_t)) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return E_FAIL;
    }
    
    // 填充头部
    center_data_header_t* header = (center_data_header_t*)pkt->payload;
    header->type = CENTER_DATA_SENSOR;
    //header->version = 0x01;
    header->srcId = center_vars.myId;
    //header->seqNum = center_vars.dataSeqNum++;
    //ieee154e_getAsn(header->timestamp);
    header->length = sizeof(center_sensor_data_t);

    if(packetfunctions_reserveHeader(&pkt, 1) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return E_FAIL;
    }
    pkt->payload[0] = CENTER_FRAME_DATA;

    // 发送到Leader
    memset(&pkt->l2_nextORpreviousHop,0,sizeof(open_addr_t));
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = member_vars.groupId;
    
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
        return E_FAIL;
    }
    
    return E_SUCCESS;
} 

void center_member_sendFrame(OpenQueueEntry_t* msg) {
    uint8_t frameType;
    uint8_t cmdType;
    
    //openserial_leader_printf("center_leader_sendFrame");
    // 提取帧类型
    //openserial_mysf_printf("pkt sent done, %s",msg->l2_sendDoneError? "FAIL":"SUCCESS");
    frameType = msg->l2_payload[0];
    //packetfunctions_tossHeader(&msg,1);
    
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
            center_data_header_t* header = (center_data_header_t*)&msg->l2_payload[1];
            switch(header->type) {
                case CENTER_DATA_SENSOR:
                    openserial_leader_printf("Sensor data forwarded");
                    break;
                    
                case CENTER_DATA_STATUS:
                    openserial_leader_printf("Status data forwarded");
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
    //openserial_leader_printf("now free pkt");

}