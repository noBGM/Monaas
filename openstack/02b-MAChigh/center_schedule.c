#include "center_schedule.h"
#include "openqueue.h"clude "openqueue.h"

//=========================== 变量 =========================================

center_vars_t center_vars;  // 全局变量定义
//=========================== 公共函数 =====================================

/**
\brief 初始化调度模块
*/
void center_init(center_role_t role, uint8_t subrole, uint8_t expectedGroup) {
    memset(&center_vars, 0, sizeof(center_vars_t));
    switch (role)
    {
        case CENTER_ROLE_ROOT:
            center_init_root();
            break;
        case CENTER_ROLE_LEADER:
            center_init_leader(subrole);
            break;
        case CENTER_ROLE_MEMBER:
            center_init_member(subrole,expectedGroup);
            break;    
        default:
            break;
    }


}

owerror_t center_addSlot_reserve(center_slot_t* slot) {
    open_addr_t owner;
    cellType_t type;

    memset(&owner,0,sizeof(open_addr_t));
    if(slot->owner != 0xFF){
        owner.type = ADDR_64B;
        owner.addr_64b[7] = slot->owner;
    }else{
        return E_SUCCESS;
    }

    if(slot->type == CELLTYPE_TX){
        type = CELLTYPE_RX;
    }
    if(slot->type == CELLTYPE_RX){
        type = CELLTYPE_TX;
    }
    return schedule_addActiveSlot(
        slot->slotOffset,
        type,
        FALSE,
        FALSE,
        slot->channelOffset,
        &owner
    );
}
/**
\brief 添加时隙
*/
owerror_t center_addSlot(center_slot_t* slot) {
    open_addr_t owner;
    memset(&owner,0,sizeof(open_addr_t));
    if(slot->owner != 0xFF){
        owner.type = ADDR_64B;
        owner.addr_64b[7] = slot->owner;
    }else{
        owner.type = ADDR_ANYCAST;
    }
    return schedule_addActiveSlot(
        slot->slotOffset,
        slot->type,
        FALSE,
        FALSE,
        slot->channelOffset,
        &owner
    );
}
void center_sendFrame(OpenQueueEntry_t *msg){
    switch(center_vars.role) {
        case CENTER_ROLE_ROOT:
            center_root_sendFrame(msg);
            break;
        case CENTER_ROLE_LEADER:
            center_leader_sendFrame(msg);
            break;
        case CENTER_ROLE_MEMBER:
            center_member_sendFrame(msg);
            break;
        default:
            break;
    }
}
void center_receiveFrame(OpenQueueEntry_t *msg){
    switch(center_vars.role) {
        case CENTER_ROLE_ROOT:
            center_root_receiveFrame(msg);
            break;
        case CENTER_ROLE_LEADER:
            center_leader_receiveFrame(msg);
            break;
        case CENTER_ROLE_MEMBER:
            center_member_receiveFrame(msg);
            break;
        default:
            break;
    }
}

void center_processBeacon(OpenQueueEntry_t *msg){
    switch (center_vars.role)
    {
    case CENTER_ROLE_ROOT:
        break;
    case CENTER_ROLE_LEADER:
        break;
    case CENTER_ROLE_MEMBER:
        member_processBeacon(msg);
        break;
    default:
        break;
    }
}

void center_processDesync(void){
    switch (center_vars.role)
    {
    case CENTER_ROLE_ROOT:
        break;
    case CENTER_ROLE_LEADER:
        break;
    case CENTER_ROLE_MEMBER:
        member_processDesync();
        break;
    default:
        break;
    }
}

void center_handleCommand(uint8_t* data, uint8_t len){
    debugPrint_queue();
}