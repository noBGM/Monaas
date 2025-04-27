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
#include "mysf_schedule.h"

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

    board_init();
    openstack_init();
    mysf_init();
    //while(1){
    openserial_printf("mote_main\n");
    //  some_delay();
    //}
    scheduler_start();
    
    return 0;

}
void some_delay(void) {
   volatile uint16_t delay;
   for (delay=0xffff;delay>0;delay--);
}

//=========================== stubbing ========================================

//===== IPHC

void iphc_init(void) {
    macpong_vars.timerId = opentimers_create(TIMER_GENERAL_PURPOSE, TASKPRIO_IPHC);
    opentimers_scheduleIn(
            macpong_vars.timerId,   // timerId
            1000,                   // duration
            TIME_MS,                // timetype
            TIMER_PERIODIC,         // timertype
            macpong_initSend        // callback
    );
}

void iphc_sendDone(OpenQueueEntry_t *msg, owerror_t sendError) {
    msg->owner = COMPONENT_IPHC;
    openqueue_freePacketBuffer(msg);
}

void iphc_receive(OpenQueueEntry_t *msg) {
    msg->owner = COMPONENT_IPHC;
    //macpong_send(++msg->payload[0]);
    openqueue_freePacketBuffer(msg);
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

    if (ieee154e_isSynch() == TRUE && neighbors_getNumNeighbors() == 1) {
        neighbors_getNeighborEui64(addressToWrite, ADDR_64B, 0);
    }
    return TRUE;
}

bool icmpv6rpl_isPreferredParent(open_addr_t *address) {

    open_addr_t temp;
    if (idmanager_getIsDAGroot() == TRUE) {
        return FALSE;
    }

    if (address->type == ADDR_64B) {
        neighbors_getNeighborEui64(&temp, ADDR_64B, 0);
        return packetfunctions_sameAddress(address, &temp);
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
