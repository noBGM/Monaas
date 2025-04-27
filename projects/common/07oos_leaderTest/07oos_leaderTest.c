/**
\brief This is a program which shows how to use the "openserial" driver module.

Since the driver modules for different platforms have the same declaration, you
can use this project with any platform.

This application allows you to test that the openserial driver it working fine.
Once your board is running this application, use the serialTesterCli Python
application (part of the openwsn-sw repo) to issue serial echo commands, making
sure all is well.

\author Xavi Vilajosana <xvilajosana@eecs.berkeley.edu>, January 2013.
\author Thomas Watteyne <watteyne@eecs.berkeley.edu>, January 2014.
*/
#include "opendefs.h"
#include "board.h"
#include "scheduler.h"
#include "openstack.h"
#include "opentimers.h"
// needed for spoofing
#include "openqueue.h"
#include "opentimers.h"
#include "IEEE802154E.h"
#include "openserial.h"
#include "packetfunctions.h"
#include "sixtop.h"
#include "idmanager.h"
#include "neighbors.h"
// mysf
//#include "mysf_schedule.h"
#include "center_schedule.h"

//=========================== defines =========================================

//static char stringToPrint[]       = "05oos_rootTest\r\n";

//=========================== variables =======================================


typedef struct {
    bool        timerFired;
    bool        fInhibit;
    open_addr_t addr;
} app_vars_t;

app_vars_t app_vars;

//=========================== prototypes ======================================


//=========================== main ============================================

/**
\brief The program starts executing here.
in order to echo chunks of bytes, each chunk needs to start with character 'H' as
openserial takes different actions according to the initial character of the stream.
*/
int mote_main(void) {
    uint8_t subrole = CENTER_GROUP_HEAD;
    
    board_init();
    openstack_init(CENTER_ROLE_LEADER, subrole, 0);
    //while(1){
    openserial_mysf_printf("leader_main");
    //  some_delay();
    //}
    scheduler_start();
    
    return 0;

}

//=========================== stubbing ========================================

//===== IPHC

void iphc_init(void) {
    return;
}

void iphc_sendDone(OpenQueueEntry_t *msg, owerror_t sendError) {
    // msg->owner = COMPONENT_IPHC;
    // openqueue_freePacketBuffer(msg);
    return;
}

void iphc_receive(OpenQueueEntry_t *msg) {
    // msg->owner = COMPONENT_IPHC;
    // //macpong_send(++msg->payload[0]);
    // openqueue_freePacketBuffer(msg);
    return;
}

//===== sniffer

void sniffer_setListeningChannel(uint8_t channel) { return; }

//===== L3

void forwarding_init(void) { return; }

void openbridge_init(void) { return; }

void openbridge_triggerData(void) { return; }

//===== L4

void icmpv6_init(void) { return; }

void icmpv6echo_init(void) { return; }

void icmpv6echo_trigger(void) { return; }

void icmpv6router_init(void) { return; }

void icmpv6router_trigger(void) { return; }

void icmpv6rpl_init(void) { return; }

void icmpv6rpl_trigger(void) { return; }

void icmpv6rpl_writeDODAGid(uint8_t *dodagid) { return; }

void icmpv6rpl_setDIOPeriod(uint16_t dioPeriod) { return; }

void icmpv6rpl_setDAOPeriod(uint16_t daoPeriod) { return; }

bool icmpv6rpl_getPreferredParentIndex(uint8_t *indexptr) {
    return FALSE;
}

bool icmpv6rpl_getPreferredParentEui64(open_addr_t *addressToWrite) {

    if (idmanager_getIsDAGroot() == TRUE) {
        return FALSE;
    }

    if (ieee154e_isSynch() == TRUE) {
        memset(addressToWrite,0,sizeof(open_addr_t));
        //neighbors_getNeighborEui64(addressToWrite, ADDR_64B, 0);
        addressToWrite->addr_64b[7] = ROOT_ID;
    }
    return TRUE;
}

bool icmpv6rpl_isPreferredParent(open_addr_t *address) {

    open_addr_t temp;
    if (idmanager_getIsDAGroot() == TRUE) {
        return FALSE;
    }

    if (address->type == ADDR_64B) {
        if(address->addr_64b[7] == center_leader_getParent()->addr_64b.addr_64b[7]){
            //openserial_leader_printf("%d,%d",address->addr_64b[7], center_leader_getParent()->addr_64b.addr_64b[7]);
            return TRUE;
        }
        return FALSE;
    } else {
        return FALSE;
    }
}

dagrank_t icmpv6rpl_getMyDAGrank(void) {
    return 0;
}

bool icmpv6rpl_daoSent(void) {
    return TRUE;
}

void icmpv6rpl_setMyDAGrank(dagrank_t rank) { return; }

void icmpv6rpl_updateMyDAGrankAndParentSelection(void) { return; }

void icmpv6echo_setIsReplyEnabled(bool isEnabled) { return; }


void udp_init(void) { return; }

void coap_init(void) { return; }

//===== L7

void openapps_init(void) { return; }
void openweb_init(void) { return; }
