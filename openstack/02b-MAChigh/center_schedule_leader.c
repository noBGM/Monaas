#include "center_schedule_leader.h"
#include "center_schedule_tasks.h"



static void leader_timer_cb(opentimers_id_t id);
static void leader_task_cb(void);
static void leader_sendBeacon(void);
static void leader_handleJoinRequest(OpenQueueEntry_t* msg);
static void leader_handleSchedule(OpenQueueEntry_t* msg);
static bool update_slot_resources(root_slot_resource_t* newSlots, uint8_t numNewSlots);
static bool do_allocation(member_monitor_t* members, uint8_t numMembers);
static void leader_processSensorData(OpenQueueEntry_t* msg);
static bool check_collection_complete(void);
static void send_aggregated_data(uint8_t subType);
static void collection_timeout_handler(opentimers_id_t id);
static void reset_collection_state(void);
static void leader_updateMemberState(uint8_t memberId, OpenQueueEntry_t* msg, uint8_t* statusData, uint8_t statusLen);
static void leader_notifyMemberStateChange(void);
static void leader_checkMemberStatus(bool noNotify);
static bool leader_checkMembersOnline(void);
static void leader_removeMember(member_monitor_t* member);
static void leader_notifyError(uint8_t errorType);
static void leader_initSchedule(void);
static owerror_t leader_sendCommand(uint8_t cmdType, uint8_t* data, uint8_t len);
static void center_leader_simulate(void);
static void member_collectSensorData(center_sensor_data_sim_t* sensorData);

leader_vars_t leader_vars;

static member_data_cache_t dataCache[LEADER_MAX_MEMBERS];
static opentimers_id_t      collectionTimer;
static bool                isCollecting = FALSE;
static int16_t index = 0;

void center_init_leader(uint8_t subrole) {
    // 重置变量
    memset(&leader_vars, 0, sizeof(leader_vars_t));
    memset(&leader_vars.resourceManager, 0, sizeof(group_resource_manager_t));
    
    
    // 设置角色
    center_vars.role = CENTER_ROLE_LEADER;
    center_vars.groupId = subrole;
    leader_vars.resourceManager.groupId = center_vars.groupId;
    center_vars.myId = subrole;//idmanager_getMyID(ADDR_64B)->addr_64b[7];
    memset(&center_vars.myId_addr, 0, sizeof(open_addr_t));
    center_vars.myId_addr.addr_64b[7] = center_vars.myId;
    center_vars.myId_addr_16.addr_16b[0] = 0;
    center_vars.myId_addr_16.addr_16b[1] = center_vars.myId_addr.addr_64b[7];

    center_vars.myId_addr.type = ADDR_64B;
    center_vars.myId_addr_16.type = ADDR_16B;
    idmanager_setMyID(&center_vars.myId_addr);
    idmanager_setMyID(&center_vars.myId_addr_16);
    // 初始化时隙分配
    leader_initSchedule();
    leader_initTaskHandler();
    
    // 注册任务回调
    //scheduler_push_task(leader_task_cb, TASKPRIO_COAP);
    
    collectionTimer = opentimers_create(TIMER_GENERAL_PURPOSE, TASKPRIO_COAP);
    leader_vars.timerId = opentimers_create(TIMER_GENERAL_PURPOSE, TASKPRIO_COAP);//状态检查定时器
    // opentimers_scheduleIn(
    //     leader_vars.timerId,
    //     LEADER_TIMER_PERIOD,
    //     TIME_MS,
    //     TIMER_PERIODIC,
    //     leader_timer_cb
    // );

    // opentimers_scheduleIn(
    //     leader_vars.timerId,
    //     LEADER_TIMER_PERIOD,
    //     TIME_MS,
    //     TIMER_PERIODIC,
    //     center_leader_simulate
    // );

}


static void member_collectSensorData(center_sensor_data_sim_t* sensorData) {
    //for (int i = 0; i < 10; i++) {
        sensorData->pos[0] = index++;  // 初始化数组
    //
}
//simulate forwarding all members data.
static void center_leader_simulate(void){
    if(ieee154e_isSynch() == FALSE){
        openserial_leader_printf("not sync");
        return;
    }
    
    //openserial_leader_printf("sim timer callback");
    OpenQueueEntry_t* pkt;
    center_sensor_data_sim_t sensorData;
    
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) 
    {   
        openserial_leader_printf("f0");
        return E_FAIL;
    }
    // 采集传感器数据
    member_collectSensorData(&sensorData);

    // 为传感器数据预留空间
    if(packetfunctions_reserveHeader(&pkt, sizeof(center_sensor_data_sim_t)) == E_FAIL) {
        openserial_leader_printf("f1");
        openqueue_freePacketBuffer(pkt);
        return E_FAIL;
    }
    
    // 填充传感器数据
    memcpy(pkt->payload, &sensorData, sizeof(center_sensor_data_sim_t));
    //pkt->length = sizeof(center_sensor_data_sim_t);
    
    // 为头部预留空间
    if(packetfunctions_reserveHeader(&pkt, sizeof(center_data_header_t)) == E_FAIL) {
        openserial_leader_printf("f2");
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
    header->length = sizeof(center_sensor_data_sim_t);
    //openserial_leader_printf("header->length==%d",header->length);

    if(packetfunctions_reserveHeader(&pkt, 1) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        openserial_leader_printf("f3");
        return E_FAIL;
    }
    pkt->payload[0]= CENTER_FRAME_DATA;
    center_leader_receiveFrame(pkt);
}


//finish sending.
void center_leader_sendFrame(OpenQueueEntry_t* msg) {
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


/**
\brief 处理接收到的数据帧
*/
void center_leader_receiveFrame(OpenQueueEntry_t* msg) {
    uint8_t frameType;
    uint8_t cmdType;
    uint8_t srcId;
    
    openserial_printData(msg->payload,msg->length);
    // 提取帧类型和源节点ID
    frameType = msg->payload[0];
    srcId = msg->l2_nextORpreviousHop.addr_64b[7];
    packetfunctions_tossHeader(&msg,1);

    //只有来自Member的消息才更新状态
    if(srcId != ROOT_ID) {  // 不是Root发来的消息
        leader_updateMemberState(srcId, msg, NULL, 0);
    }    
    
    switch(frameType) {
        case CENTER_FRAME_DATA:
            // 处理数据帧
            center_data_header_t* header = (center_data_header_t*)msg->payload;
            packetfunctions_tossHeader(&msg,sizeof(center_data_header_t));
            switch(header->type) {
                case CENTER_DATA_SENSOR:
                    leader_processSensorData(msg);
                    break;
                    
                case CENTER_DATA_STATUS:
                    // 更新组员状态
                    leader_updateMemberState(srcId, msg,
                                          msg->payload,
                                          header->length);
                    break;
                    
                default:
                    break;
            }
            break;
            
        case CENTER_FRAME_COMMAND:
            cmdType = msg->payload[0];
            packetfunctions_tossHeader(&msg,1);
            switch(cmdType) {
                case CENTER_CMD_JOIN_REQ:
                    leader_handleJoinRequest(msg);
                    break;
                    
                case CENTER_CMD_SCHEDULE:
                    //if(srcId == ROOT_ID) {  // 只处理来自Root的调度表更新
                    leader_handleSchedule(msg);
                    //}
                    break;
                case CENTER_CMD_START:
                    if(srcId == ROOT_ID){
                        if(leader_checkMembersOnline()){
                            leader_sendCommand(CENTER_CMD_START,NULL,0);
                        }else{
                            leader_notifyError(ERR_CENTER_MEMBERS_NOT_READY);
                        }
                    }
                    break;
                case CENTER_CMD_MACTEST:
                    if(srcId == ROOT_ID) {  // 来自Root的测试命令
                        openserial_leader_printf("receive mactest");
                        mac_test_pkt_t* testPkt = (mac_test_pkt_t*)msg->payload;
                        int i;
                        // 检查目标节点是否在本组
                        for(i=0; i<LEADER_MAX_MEMBERS; i++) {
                            if(leader_vars.members[i].id == testPkt->targetId && leader_vars.members[i].state == NODE_STATE_ONLINE) {
                                // 转发测试命令给目标Member
                                leader_sendCommand(CENTER_CMD_MACTEST, 
                                                 (uint8_t*)testPkt, 
                                                 sizeof(mac_test_pkt_t) + testPkt->payload[0]);
                                return;
                            }
                        }
                        // 目标节点不存在或离线,返回错误
                        leader_notifyError(ERR_CENTER_INVALID_MEMBER);
                    }
                    break;
                case CENTER_CMD_MACTEST_RESP:
                    // 来自Member的测试响应,转发给Root
                    OpenQueueEntry_t* pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
                    if(pkt == NULL) return;
                    
                    // 为响应数据预留空间
                    if(packetfunctions_reserveHeader(&pkt, msg->length) == E_FAIL) {
                        openqueue_freePacketBuffer(pkt);
                        return;
                    }
                    
                    // 复制响应数据
                    memcpy(pkt->payload, msg->payload, msg->length);
                    //pkt->length = msg->length-2;
                    
                    // 为头部预留空间
                    if(packetfunctions_reserveHeader(&pkt, 2) == E_FAIL) {
                        openqueue_freePacketBuffer(pkt);
                        return;
                    }
                    
                    // 填充头部
                    pkt->payload[0] = CENTER_FRAME_COMMAND;
                    pkt->payload[1] = CENTER_CMD_MACTEST_RESP;
                    
                    // 发送到Root
                    pkt->l2_nextORpreviousHop.type = ADDR_64B;
                    pkt->l2_nextORpreviousHop.addr_64b[7] = ROOT_ID;
                    
                    if(sixtop_send(pkt) != E_SUCCESS) {
                        openqueue_freePacketBuffer(pkt);
                    }
                    break;
                case CENTER_CMD_TASK_REQ:
                    leader_handleTask(msg);
                    break;

                case CENTER_CMD_TASK_PROGRESS:
                    leader_handleTaskProgress(msg);
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

void center_leader_setParent(neighborRow_t* parent){
    openserial_leader_printf("center_leader_setParent");
    leader_vars.parent = parent;
    return;
}
neighborRow_t* center_leader_getParent(){
    return leader_vars.parent;
}

//=========================== 私有函数 =====================================

/**
\brief 定时器回调函数
*/
static void leader_timer_cb(opentimers_id_t id) {
    //scheduler_push_task(leader_task_cb, TASKPRIO_COAP);
}

/**
\brief 组长任务回调函数
*/
static void leader_task_cb(void) {
    // 发送周期性信标
    //leader_sendBeacon();
    
    // 检查组员状态 汇报的内存太大了，critical
    leader_checkMemberStatus(FALSE);
    
    // // 重新调度任务//栈爆炸了
    // scheduler_push_task(leader_task_cb, TASKPRIO_COAP);
}

/**
\brief 发送信标帧
*/
static void leader_sendBeacon(void) {
    OpenQueueEntry_t* pkt;
    uint8_t len = 0;
    
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) return;
    
    // 准备信标数据
    pkt->payload[len++] = CENTER_FRAME_BEACON;
    pkt->payload[len++] = leader_vars.beaconSeqNum++;
    pkt->payload[len++] = center_vars.groupId;
    pkt->payload[len++] = leader_vars.numMembers;
    pkt->payload[len++] = leader_vars.scheduleVersion;
    
    // 设置数据包长度
    pkt->length = len;
    
    // 广播信标
    pkt->l2_nextORpreviousHop.type = ADDR_ANYCAST;
    
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }
}

/**
\brief 处理加入请求
*/
static void leader_handleJoinRequest(OpenQueueEntry_t* msg) {
    uint8_t memberId,memberGroupID;
    uint8_t i;
    openserial_leader_printf("leader_handleJoinRequest");
    // 提取成员ID
    memberGroupID = msg->payload[0];
    memberId = msg->payload[1];
    if(memberGroupID != center_vars.groupId){
        return;
    }
    // 检查是否有空闲位置
    if(leader_vars.numMembers >= LEADER_MAX_MEMBERS
        || memberId >= LEADER_MAX_MEMBERS) {
        return;
    }
    
    leader_vars.members[memberId].id = memberId;
    leader_vars.members[memberId].state = NODE_STATE_ONLINE;
    leader_vars.members[memberId].joinState = 1;
    leader_vars.members[memberId].linkStat.rssi = msg->l1_rssi;
    leader_vars.members[memberId].linkStat.lqi = msg->l1_lqi;
    ieee154e_getAsn(leader_vars.members[memberId].linkStat.lastActive);
    leader_vars.members[memberId].linkStat.pdr = 100;
    leader_vars.members[memberId].isTaskActive = FALSE;
    leader_vars.numMembers++;
    leader_vars.freeMembers++;

    openserial_leader_printf("member %d is online",memberId);
    
    task_mayStart();
}


//用于schedule接受转发测试
void leader_handleCommand(uint8_t* data, uint8_t len){
    OpenQueueEntry_t* pkt;

    if(data[0] == 0x00){
        pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
        if(pkt == NULL){
            openserial_leader_printf("no free packet buffer");
            return;
        } 
        packetfunctions_reserveHeader(&pkt, len);
        memcpy(pkt->payload, data, len);

        packetfunctions_reserveHeader(&pkt, 2);
        pkt->payload[0] = 2; //CENTER_FRAME_COMMAND
        pkt->payload[1] = 1; //CENTER_COMMAND_SCHEDULE
        leader_handleSchedule(pkt);
        openqueue_freePacketBuffer(pkt);
    }else if(data[0] == 0x01){
        pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
        if(pkt == NULL){
            openserial_leader_printf("no free packet buffer");
            return;
        } 
        packetfunctions_reserveHeader(&pkt, 63);

        uint8_t temp[63] = {0,2,1,3,50,1,7,3,1,4,3,4,5,6,0,4,1,4,3,4,5,6,0,5,1,4,3,4,5,6,0,6,
                            1,4,3,4,5,6,0,7,1,4,3,4,5,6,0,8,1,4,3,4,5,6,0,9,1,4,3,4,5,6,0};
        memcpy(pkt->payload, temp, 63);

        // packetfunctions_reserveHeader(&pkt, 2);
        // pkt->payload[0] = 2; //CENTER_FRAME_COMMAND
        // pkt->payload[1] = 16; //CENTER_CMD_TASK_REQ
        leader_handleTask(pkt);
        openqueue_freePacketBuffer(pkt);
    }
}


// 更新时隙资源(从root接收新的资源分配时调用)
static bool update_slot_resources(root_slot_resource_t* newSlots, uint8_t numNewSlots) {
    openserial_leader_printf("update_slot_resources");
    if(numNewSlots > MAX_SLOT_RESOURCES) return FALSE;
    
    leader_vars.resourceManager.numSlots = numNewSlots;
    
    // 更新每个时隙的资源
    for(uint8_t i = 0; i < numNewSlots; i++) {
        slot_resource_t* slot = &leader_vars.resourceManager.slots[i];
        slot->slotOffset = newSlots[i].slotOffset;
        slot->type = newSlots[i].type;
        slot->owner = 0; // 初始未分配
        
        // 更新该时隙的所有可用信道
        slot->numChannels = newSlots[i].numChannels;
        if(slot->numChannels > MAX_CHANNELS_PER_SLOT) {
            slot->numChannels = MAX_CHANNELS_PER_SLOT;  // 限制最大信道数
        }
        
        // 初始化每个可用信道
        for(uint8_t j = 0; j < slot->numChannels; j++) {
            channel_resource_t* channel = &slot->channels[j];
            channel->channelOffset = newSlots[i].channelOffsets[j];
            channel->isActive = 0;  // 默认使用第一个信道
            channel->currentQuality = 100;  // 初始质量最好
            channel->lastSwitchTime = 0;
            channel->historyIndex = 0;
            
            // 清空历史记录
            memset(channel->qualityHistory, 0, 
                   sizeof(channel_quality_record_t) * QUALITY_HISTORY_SIZE);
        }
    }
    
    openserial_leader_printf("Updated %d slots with multiple channels", numNewSlots);
    return TRUE;
}


/**
\brief 处理调度表更新
*/
static void leader_handleSchedule(OpenQueueEntry_t* msg) {
    center_schedule_header_t* header;
    center_schedule_ack_t ack;
    OpenQueueEntry_t* pkt;
    root_slot_resource_t* newSlots;
    uint8_t i, numNewSlots;
    bool success = TRUE;
    openserial_leader_printf("leader_handleSchedule");

    // 解析头部
    header = (center_schedule_header_t*)&msg->payload[0];
    // 检查组ID
    if(header->groupId != center_vars.groupId) {
        return;
    }
    newSlots = (root_slot_resource_t*)&msg->payload[sizeof(center_schedule_header_t)];
    numNewSlots = header->numSlots;

    // 更新本地资源管理器
    if(!update_slot_resources(newSlots, numNewSlots)) {
        // 处理更新失败的情况
        leader_notifyError(ERR_CENTER_SCHEDULE_UPDATE_FAIL);
        return;
    }
    if(!do_allocation(leader_vars.members, leader_vars.numMembers)) {
        leader_notifyError(ERR_CENTER_ALLOCATION_FAIL);
        return;
    }

    // // 准备确认包
    // pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    // if(pkt == NULL) return;
    
    // // 填充确认信息
    // ack.version = header->version;
    // ack.status = success ? 0 : 1;
    // ack.groupId = center_vars.groupId;
    
    // // 准备数据包
    // pkt->payload[0] = CENTER_FRAME_COMMAND;
    // pkt->payload[1] = CENTER_CMD_SCHED_ACK;
    // memcpy(&pkt->payload[2], &ack, sizeof(ack));
    // pkt->length = 2 + sizeof(ack);
    
    // // 发送到Root
    // pkt->l2_nextORpreviousHop.type = ADDR_64B;
    // pkt->l2_nextORpreviousHop.addr_64b[7] = ROOT_ID; // Root ID
    
    // if(sixtop_send(pkt) != E_SUCCESS) {
    //     openqueue_freePacketBuffer(pkt);
    // }
}
/**
\brief 执行组内资源分配
\param members 组内成员数组
\param numMembers 成员数量
\return 分配是否成功
*/
static bool do_allocation(member_monitor_t* members, uint8_t numMembers) {
    uint8_t onlineMembers = 0;
    uint8_t slotsPerMember;
    uint8_t extraSlots;
    uint8_t currentSlot = 0;
    center_slot_t __slot;
    openserial_leader_printf("do_allocation");
    // 第一步：计算在线成员数量
    for(uint8_t i = 0; i < numMembers; i++) {
        if(members[i].state == NODE_STATE_ONLINE) {
            onlineMembers++;
        }
    }
    
    if(onlineMembers == 0) {
        openserial_leader_printf("No online members");
        return FALSE;
    }
    
    // 第二步：计算基本分配方案
    slotsPerMember = leader_vars.resourceManager.numSlots / onlineMembers;  // 每个成员基本分配数
    extraSlots = leader_vars.resourceManager.numSlots % onlineMembers;      // 剩余待分配时隙
    
    // 清除现有分配
    schedule_removeAllMoveableCells();
    OpenQueueEntry_t* memberPkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(memberPkt == NULL) {
        openserial_leader_printf("No free packet buffer");
        return;
    }
    
    // 第三步：为每个在线成员分配时隙
    for(uint8_t i = 0; i < numMembers; i++) {
        if(members[i].state != NODE_STATE_ONLINE) continue;
        
        uint8_t allocatedSlots = slotsPerMember;
        // 分配额外时隙(优先给高优先级成员)
        if(extraSlots > 0 && members[i].priority > 0) {
            allocatedSlots++;
            extraSlots--;
        }
        
        // 为该成员分配时隙
        for(uint8_t j = 0; j < allocatedSlots && currentSlot < leader_vars.resourceManager.numSlots; j++) {
            slot_resource_t* slot = &leader_vars.resourceManager.slots[currentSlot];
            slot->owner = members[i].id;
            center_slot_t __slot = {
                .slotOffset = slot->slotOffset,
                .channelOffset = slot->channels[0].channelOffset,
                .type = slot->type,
                .owner = slot->owner
            }; 
            
            if(center_addSlot_reserve(&__slot)!=E_SUCCESS){
                leader_notifyError(ERR_CENTER_SCHEDULE_UPDATE_FAIL);
                schedule_removeAllMoveableCells();
                openqueue_freePacketBuffer(memberPkt);
                return;
            }
            packetfunctions_reserveHeader(&memberPkt, sizeof(center_slot_t));  
            memcpy(memberPkt->payload, &__slot, sizeof(center_slot_t));

            openserial_leader_printf("Allocated slot %d (ch:%d) to member %d",
                                   __slot.slotOffset, __slot.channelOffset, __slot.owner);
            
            currentSlot++;
        }
    }

    packetfunctions_reserveHeader(&memberPkt,2 + sizeof(center_schedule_header_t));  
    memberPkt->payload[0] = CENTER_FRAME_COMMAND;
    memberPkt->payload[1] = CENTER_CMD_SCHEDULE;
    
    // 修改头部信息
    center_schedule_header_t memberHeader;
    //memberHeader.version = header->version;
    memberHeader.numSlots = currentSlot;
    memberHeader.groupId = center_vars.groupId;
    
    memcpy(&memberPkt->payload[2], &memberHeader, sizeof(memberHeader));
    //memberPkt->length = 2 + sizeof(memberHeader) + currentSlot * sizeof(center_slot_t);
    
    // 广播给组内成员
    memberPkt->l2_nextORpreviousHop.type = ADDR_ANYCAST;

    
    if(sixtop_send(memberPkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(memberPkt);
        //success = FALSE;
        openserial_leader_printf("schedule send fail");
    }else{
        openserial_leader_printf("schedule send success");
    }

    // 第四步：分配剩余的额外时隙(如果还有)
    // while(extraSlots > 0 && currentSlot < leader_vars.resourceManager.numSlots) {
    //     // 找到通信质量最差的在线成员
    //     uint8_t worstMemberId = 0;
    //     uint8_t worstQuality = 255;
        
    //     for(uint8_t i = 0; i < numMembers; i++) {
    //         if(members[i].state == NODE_STATE_ONLINE) {
    //             uint8_t quality = members[i].linkStat.pdr;
    //             if(quality < worstQuality) {
    //                 worstQuality = quality;
    //                 worstMemberId = members[i].id;
    //             }
    //         }
    //     }
        
    //     // 为通信质量最差的成员分配额外时隙
    //     slot_resource_t* slot = &leader_vars.resourceManager.slots[currentSlot];
    //     slot->owner = worstMemberId;
        
    //     // 选择初始信道
    //     uint8_t selectedChannel = slot->channels[0].channelOffset;
    //     if(center_addSlot_reserve(&__slot)!=E_SUCCESS){
    //         leader_notifyError(ERR_CENTER_SCHEDULE_UPDATE_FAIL);
    //         schedule_removeAllMoveableCells();
    //         return;
    //     }        
        
    //     openserial_leader_printf("Allocated extra slot %d (ch:%d) to member %d",
    //                            slot->slotOffset, selectedChannel, worstMemberId);
        
    //     currentSlot++;
    //     extraSlots--;
    // }
    
    // 第五步：打印分配结果统计
    openserial_leader_printf("Allocation complete: %d slots allocated to %d members",
                           currentSlot, onlineMembers);
    
    return TRUE;
}


/**
\brief 处理并聚合传感器数据
*/
static void leader_processSensorData(OpenQueueEntry_t* msg) {
    uint8_t memberId;
    uint8_t i;

    
    // 提取源节点ID
    memberId = msg->l2_nextORpreviousHop.addr_64b[7];
    openserial_leader_printf("leader_processSensorData: %d", memberId);
    // 检查是否是组内成员
    for(i=0; i<LEADER_MAX_MEMBERS; i++) {
        if(leader_vars.members[i].id == memberId &&
           leader_vars.members[i].state != NODE_STATE_OFFLINE) {
            break;
        }
    }
    if(i >= LEADER_MAX_MEMBERS) {
        openserial_leader_printf("i >= LEADER_MAX_MEMBERS");
        return; // 不是活跃成员,丢弃数据
    }

    // 缓存数据
    if(msg->length > MAX_CACHED_DATA_SIZE) {
        openserial_leader_printf("Data too big from %d", memberId);
        return;
    }
    
    memcpy(dataCache[memberId].data, msg->payload, msg->length);
    dataCache[memberId].length = msg->length;
    dataCache[memberId].received = TRUE;

    // 如果是第一个收到的数据，启动超时定时器
    if(!isCollecting) {
        isCollecting = TRUE;
        opentimers_scheduleIn(
            collectionTimer,
            COLLECTION_TIMEOUT, 
            TIMER_ONESHOT, 
            TIME_MS,
            collection_timeout_handler);
    }

    // 检查是否收集完成
    if(check_collection_complete()) {
        send_aggregated_data(CENTER_DATA_SENSOR);
        reset_collection_state();
    }
}

/**
\brief 检查是否所有在线成员数据都已收到
*/
static bool check_collection_complete(void) {
    
    for(uint8_t i=0; i<LEADER_MAX_MEMBERS; i++) {
        if(leader_vars.members[i].state != NODE_STATE_OFFLINE &&
           !dataCache[leader_vars.members[i].id].received) {
            openserial_leader_printf("check_collection_complete FALSE");
            return FALSE;
        }
    }
    openserial_leader_printf("check_collection_complete TRUE");
    return TRUE;
}

/**
\brief 发送聚合后的数据包
*/
static void send_aggregated_data(uint8_t subType) {
    uint16_t numEntries = 0;
    uint16_t length = 0;
    openserial_leader_printf("send_aggregated_data");

    OpenQueueEntry_t* pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(!pkt) {
        openserial_leader_printf("Aggregate packet alloc fail");
        return;
    }

    // 添加各成员数据
    for(uint8_t i=0; i<LEADER_MAX_MEMBERS; i++) {
        //uint8_t id =leader_vars.members[i].id;
        if(dataCache[i].received) {
            openserial_leader_printf("dataCache[%d].received TRUE", i);
            // 复制数据内容
            packetfunctions_reserveHeader(&pkt, dataCache[i].length);
            memcpy(pkt->payload, dataCache[i].data, dataCache[i].length);
            // 添加成员数据头
            packetfunctions_reserveHeader(&pkt, sizeof(center_member_data_header_t));
            center_member_data_header_t* dataHeader = (center_member_data_header_t*)(pkt->payload);
            dataHeader->memberID = i;
            dataHeader->dataLength = dataCache[i].length;
            
            numEntries++;
            length += dataCache[i].length + sizeof(center_member_data_header_t);
        }
    }
    // 预留头部空间
    packetfunctions_reserveHeader(&pkt, sizeof(center_aggregate_header_t));
    center_aggregate_header_t* header = (center_aggregate_header_t*)pkt->payload;
    
    header->frameType = CENTER_FRAME_DATA;
    header->subType = subType;
    //header->groupID = center_vars.groupId;
    header->numEntries = numEntries;

    // 更新数据包长度
    //pkt->length = length + sizeof(center_aggregate_header_t);
    
    // 发送到Root
    memset(&pkt->l2_nextORpreviousHop,0,sizeof(open_addr_t));
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = ROOT_ID;
    
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }
}

/**
\brief 超时处理函数
*/
static void collection_timeout_handler(opentimers_id_t id) {
    (void)id;
    openserial_leader_printf("Data collection timeout");
    send_aggregated_data(CENTER_DATA_SENSOR);
    reset_collection_state();
}

/**
\brief 重置收集状态
*/
static void reset_collection_state(void) {
    openserial_leader_printf("reset_collection_state");
    isCollecting = FALSE;
    for(uint8_t i=0; i<LEADER_MAX_MEMBERS; i++) {
        dataCache[i].received = FALSE;
        dataCache[i].length = 0;
    }
    opentimers_cancel(collectionTimer);
}

/**
\brief 更新Member状态
*/
static void leader_updateMemberState(uint8_t memberId, OpenQueueEntry_t* msg, uint8_t* statusData, uint8_t statusLen) {
    uint8_t i;
    member_monitor_t* member = NULL;
    uint8_t emptySlot = LEADER_MAX_MEMBERS;
    
    // 先查找已存在的Member
    for(i=0; i<LEADER_MAX_MEMBERS; i++) {
        if(leader_vars.members[i].id == memberId && leader_vars.members[i].state != NODE_STATE_OFFLINE) {
            openserial_leader_printf("update member %d",memberId);
            member = &leader_vars.members[i];
            break;
        }
        // 记录第一个空闲位置
        if(leader_vars.members[i].state == NODE_STATE_OFFLINE && emptySlot == LEADER_MAX_MEMBERS) {
            emptySlot = i;
        }
    }
    
    // 如果没找到已存在的Member，且有空闲位置，则创建新的
    if(member == NULL && emptySlot < LEADER_MAX_MEMBERS) {
        // member = &leader_vars.members[emptySlot];
        // member->id = memberId;
        // member->state = NODE_STATE_ONLINE;
        // member->joinState = MEMBER_JOIN_STATE_NONE;
        // member->linkStat.pdr = 100;
        // leader_vars.numMembers++;
        openserial_leader_printf("can't find member %d", memberId);
        member = &leader_vars.members[memberId];
        member->id = memberId;
        member->state = NODE_STATE_ONLINE;
        member->joinState = MEMBER_JOIN_STATE_NONE;
        member->linkStat.pdr = 100;
        leader_vars.numMembers++;
    }
    
    if(member == NULL) {
        // 没有可用位置，通知错误
        leader_notifyError(ERR_CENTER_NO_FREE_MEMBER_SLOT);
        return;
    }
    
    // 更新连接质量
    member->linkStat.rssi = msg->l1_rssi;
    member->linkStat.lqi = msg->l1_lqi;
    ieee154e_getAsn(member->linkStat.lastActive);
    
    // 更新PDR
    if(msg->l2_retriesLeft == TXRETRIES) {
        member->linkStat.pdr = ((member->linkStat.pdr * 9) + 100) / 10;
    } else {
        member->linkStat.pdr = ((member->linkStat.pdr * 9) + 
                               (100 * msg->l2_retriesLeft) / 
                               TXRETRIES) / 10;
    }
    
    // 更新状态数据
    if(statusData && statusLen > 0) {
        member->battery = statusData[0];
    }
    
    // 检查状态变化
    node_state_t newState = member->state;
    
    if(member->linkStat.pdr < NODE_PDR_THRESHOLD) {
        if(member->state == NODE_STATE_ONLINE) {
            newState = NODE_STATE_UNSTABLE;
        }
    } else {
        if(member->state == NODE_STATE_UNSTABLE) {
            newState = NODE_STATE_ONLINE;
        }
    }
    
    if(member->state != newState) {
        openserial_leader_printf("member:%d, pdr:%d",member->id,member->linkStat.pdr);
        member->state = newState;
        //leader_notifyMemberStateChange();
    }
}

/**
\brief 向Root通知Member状态变化
*/
static void leader_notifyMemberStateChange(void) {
    openserial_leader_printf("leader_notifyMemberStateChange");
    OpenQueueEntry_t* pkt;
    uint8_t i;
    uint8_t numActiveMembers = 0;
    uint8_t stateDataLen = 0;
    
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) return;
    
    // 计算活跃成员数和状态数据长度
    for(i=0; i<LEADER_MAX_MEMBERS; i++) {
        if(leader_vars.members[i].state != NODE_STATE_OFFLINE) {
            numActiveMembers++;
            stateDataLen += 7;  // 每个成员8字节状态数据
        }
    }
    
    // 为状态数据预留空间
    if(packetfunctions_reserveHeader(&pkt, stateDataLen) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    stateDataLen = 0;
    // 遍历所有Member并添加其状态
    for(i=0; i<LEADER_MAX_MEMBERS; i++) {
        member_monitor_t* member = &leader_vars.members[i];
        if(member->state == NODE_STATE_OFFLINE) continue;
        
        // 填充状态数据
        pkt->payload[stateDataLen++] = member->id;
        pkt->payload[stateDataLen++] = member->state;
        pkt->payload[stateDataLen++] = member->linkStat.pdr;
        pkt->payload[stateDataLen++] = member->linkStat.rssi;
        pkt->payload[stateDataLen++] = member->linkStat.lqi;
        pkt->payload[stateDataLen++] = member->battery;
        pkt->payload[stateDataLen++] = member->joinState;
    }
    
    
    // 为头部预留空间
    if(packetfunctions_reserveHeader(&pkt, 4) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    // 填充头部
    pkt->payload[0] = CENTER_FRAME_EVENT;
    pkt->payload[1] = CENTER_EVENT_STATE_CHANGE;
    pkt->payload[2] = center_vars.groupId;
    pkt->payload[3] = numActiveMembers;
    
    // 发送到Root
    memset(&pkt->l2_nextORpreviousHop,0,sizeof(open_addr_t));
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = ROOT_ID; // Root ID
    
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }
}

static bool leader_checkMembersOnline(void){
    leader_checkMemberStatus(TRUE);
    return (leader_vars.membersActive == 1 << LEADER_MAX_MEMBERS - 1);
}
/**
\brief 检查Member状态
*/
static void leader_checkMemberStatus(bool noNotify) {
    uint8_t i;
    asn_t lastAsn;
    bool notify = FALSE;
    
    for(i=0; i<LEADER_MAX_MEMBERS; i++) {
        member_monitor_t* member = &leader_vars.members[i];
        if(member->state == NODE_STATE_OFFLINE) continue;
        
        // 检查超时
        ieee154e_orderToASNStructure(member->linkStat.lastActive,&lastAsn);
        uint32_t timeSinceLastActive = ieee154e_asnDiff(&lastAsn);
        
        if(timeSinceLastActive > NODE_TIMEOUT_OFFLINE) {
            if(member->state != NODE_STATE_OFFLINE) {
                member->state = NODE_STATE_OFFLINE;
                openserial_leader_printf("member %d is offline", member->id);
                notify = TRUE;
                // 移除离线Member
                member->id = -1;
                leader_vars.numMembers--;
            }
        } else if(timeSinceLastActive > NODE_TIMEOUT_UNSTABLE) {
            if(member->state == NODE_STATE_ONLINE) {
                member->state = NODE_STATE_UNSTABLE;
                notify = TRUE;
            }
        }else{
            leader_vars.membersActive |= 1 << i;
        }
        if(!noNotify && notify){
            leader_notifyMemberStateChange();
        }
    }
}

/**
\brief 移除Member
*/
static void leader_removeMember(member_monitor_t* member) {
    // 通知状态变化
    member->state = NODE_STATE_OFFLINE;
    leader_notifyMemberStateChange();
    
    // 清除所有状态
    memset(member, 0, sizeof(member_monitor_t));
    leader_vars.numMembers--;
}

/**
\brief 通知错误
*/
static void leader_notifyError(uint8_t errorType) {
    OpenQueueEntry_t* pkt;
    
    openserial_leader_printf("leader_notifyError");
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) return;
    
    // 为头部预留空间
    if(packetfunctions_reserveHeader(&pkt, 5) == E_FAIL) {
        openqueue_freePacketBuffer(pkt);
        return;
    }
    
    // 准备错误通知数据包
    pkt->payload[0] = CENTER_FRAME_EVENT;
    pkt->payload[1] = CENTER_EVENT_ERROR;  // 错误事件
    pkt->payload[2] = errorType;
    pkt->payload[3] = 0;
    pkt->payload[4] = 0;
    
    // 发送到Root
    memset(&pkt->l2_nextORpreviousHop,0,sizeof(open_addr_t));
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = ROOT_ID;
    
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }
}

/**
\brief Leader节点初始化时隙分配
*/
static void leader_initSchedule(void) {
    center_slot_t slot;
    open_addr_t neighbor;
    uint8_t myIndex;
    
    // 初始化邻居地址(Root)
    memset(&neighbor, 0x00, sizeof(neighbor));
    neighbor.type = ADDR_64B;
    neighbor.addr_64b[7] = ROOT_ID;  // Root ID固定为0x11
    
    // 计算自己的索引(从1开始)
    myIndex = center_vars.groupId;
    openserial_leader_printf("myIndex:%d",myIndex);
    // 配置上行时隙(Leader->Root)
    slot.slotOffset = LEADER_UPLINK_SLOT;
    slot.channelOffset = LEADER_UPLINK_CHANNEL;
    slot.type = CELLTYPE_TX;  // Leader发送
    //openserial_leader_printf("slotOffset:%d",slot.slotOffset);
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
    
    // 记录时隙状态
    // center_vars.slots[slot.slotOffset].isUsed = TRUE;
    // center_vars.slots[slot.slotOffset].ownerId = center_vars.myId;
    // center_vars.slots[slot.slotOffset].type = slot.type;
    
    // 配置下行时隙(Root->Leader)
    slot.slotOffset = LEADER_DOWNLINK_SLOT;
    slot.channelOffset = LEADER_DOWNLINK_CHANNEL;
    slot.type = CELLTYPE_RX;  // Leader接收
    //openserial_leader_printf("%d",LEADER_DOWNLINK_SLOT);
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
    
    // 记录时隙状态
    // center_vars.slots[slot.slotOffset].isUsed = TRUE;
    // center_vars.slots[slot.slotOffset].ownerId = center_vars.myId;
    // center_vars.slots[slot.slotOffset].type = slot.type;

    // 配置组内广播时隙(Leader->Member)
    slot.slotOffset = LEADER_BROADCAST_SLOT;//CENTER_SLOT_BROADCAST + myIndex;
    slot.channelOffset = LEADER_BORADCAST_CHANNEL;
    slot.type = CELLTYPE_TX;  // Leader接收
    neighbor.type = ADDR_ANYCAST;
    
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
    
    // 记录时隙状态
    // center_vars.slots[slot.slotOffset].isUsed = TRUE;
    // center_vars.slots[slot.slotOffset].ownerId = center_vars.myId;
    // center_vars.slots[slot.slotOffset].type = slot.type;

    // 配置上行时隙(memebr->Leader) 
    for(uint8_t i = 0; i < CENTER_MAX_MEMBERS; i++){
        slot.slotOffset = LEADER_MEMBER_UPLINK_SLOT_BASE + i;
        slot.channelOffset = LEADER_MEMBER_UPLINK_CHANNEL_BASE;
        slot.type = CELLTYPE_RX;  // Leader接收Member的入组确认。
        neighbor.type = ADDR_64B;
        neighbor.addr_64b[7] = i;  // 组员
        //openserial_leader_printf("%d",LEADER_DOWNLINK_SLOT);
        if(schedule_addActiveSlot(
            slot.slotOffset,
            slot.type,
            FALSE,          //入组变化在长期看来是相对静态的，所以也可采用共享时隙。
            FALSE,         
            slot.channelOffset,
            &neighbor
        ) != E_SUCCESS) {
            // 错误处理
            return;
        }
    }
    
    // // 记录时隙状态
    // center_vars.slots[slot.slotOffset].isUsed = TRUE;
    // center_vars.slots[slot.slotOffset].ownerId = center_vars.myId;
    // center_vars.slots[slot.slotOffset].type = slot.type;

    // 配置下行时隙(Leader->memebr) 
    for(uint8_t i = 0; i < CENTER_MAX_MEMBERS; i++){
        slot.slotOffset = LEADER_MEMBER_DOWNLINK_SLOT_BASE + i;
        slot.channelOffset = LEADER_MEMBER_DOWNLINK_CHANNEL_BASE;
        slot.type = CELLTYPE_TX;  // Leader接收Member的入组确认。
        neighbor.type = ADDR_64B;
        neighbor.addr_64b[7] = i;  // 组员
        //openserial_leader_printf("%d",LEADER_DOWNLINK_SLOT);
        if(schedule_addActiveSlot(
            slot.slotOffset,
            slot.type,
            FALSE,          //入组变化在长期看来是相对静态的，所以也可采用共享时隙。
            FALSE,         
            slot.channelOffset,
            &neighbor
        ) != E_SUCCESS) {
            // 错误处理
            return;
        }
    }
}

/**
\brief 向组内成员发送命令
\param cmdType 命令类型(CENTER_CMD_XXX)
\param data    命令数据
\param len     数据长度
\return E_SUCCESS 发送成功
        E_FAIL    发送失败
*/
static owerror_t leader_sendCommand(uint8_t cmdType, uint8_t* data, uint8_t len) {
    OpenQueueEntry_t* pkt;
    center_schedule_ack_t ack;
    uint8_t pktLen = 0;
    openserial_leader_printf("leader_sendCommand");
    // 分配数据包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) {
        return E_FAIL;
    }
    if (packetfunctions_reserveHeader(&pkt, len) == E_FAIL){
        return E_FAIL;
    }
    // 添加命令数据
    if(data != NULL && len > 0) {
        memcpy(pkt->payload, data, len);
        pktLen += len;
    }
    //pkt->length = pktLen;
    
    if (packetfunctions_reserveHeader(&pkt, 2) == E_FAIL){
        return E_FAIL;
    }
    // 准备命令包
    pkt->payload[0] = CENTER_FRAME_COMMAND;  // 帧类型
    pkt->payload[1] = cmdType;              // 命令类型
    
    // 设置为广播发送
    pkt->l2_nextORpreviousHop.type = ADDR_ANYCAST;
    
    // 使用组内广播时隙发送
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
        return E_FAIL;
    }
        // 准备确认包
    pkt = openqueue_getFreePacketBuffer(COMPONENT_CENTER_SCHEDULE);
    if(pkt == NULL) return;
    
    // 填充确认信息
    ack.version = 0;
    ack.status = 0; //success
    ack.groupId = center_vars.groupId;
    
    // 准备数据包
    pkt->payload[0] = CENTER_FRAME_COMMAND;
    pkt->payload[1] = CENTER_CMD_SCHED_ACK;
    memcpy(&pkt->payload[2], &ack, sizeof(ack));
    //pkt->length = 2 + sizeof(ack);
    
    // 发送到Root
    pkt->l2_nextORpreviousHop.type = ADDR_64B;
    pkt->l2_nextORpreviousHop.addr_64b[7] = ROOT_ID; // Root ID
    
    if(sixtop_send(pkt) != E_SUCCESS) {
        openqueue_freePacketBuffer(pkt);
    }
    return E_SUCCESS;
} 

bool isOkToSendEB(void){

    if(leader_vars.numMembers < LEADER_MIN_MEMBERS){
        return TRUE;
    }

    return leader_vars.ebEnabled;
}