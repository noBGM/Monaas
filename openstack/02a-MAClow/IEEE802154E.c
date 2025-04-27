#include "config.h"
#include "opendefs.h"
#include "IEEE802154E.h"
#include "radio.h"
#include "IEEE802154.h"
#include "IEEE802154_security.h"
#include "openqueue.h"
#include "idmanager.h"
#include "openserial.h"
#include "schedule.h"
#include "packetfunctions.h"
#include "scheduler.h"
#include "leds.h"
#include "neighbors.h"
#include "debugpins.h"
#include "sixtop.h"
#include "adaptive_sync.h"
#include "sctimer.h"
#include "openrandom.h"
#include "msf.h"
//#include "mysf_schedule.h"
#include "center_schedule.h"
#include "center_schedule_leader.h"

//=========================== definition ======================================

//=========================== variables =======================================

ieee154e_vars_t ieee154e_vars;
ieee154e_stats_t ieee154e_stats;
ieee154e_dbg_t ieee154e_dbg;

//=========================== prototypes ======================================

// SYNCHRONIZING
void activity_synchronize_newSlot(void);

void activity_synchronize_startOfFrame(PORT_TIMER_WIDTH capturedTime);

void activity_synchronize_endOfFrame(PORT_TIMER_WIDTH capturedTime);

// TX
void activity_ti1ORri1(void);

void activity_ti2(void);

void activity_tie1(void);

void activity_ti3(void);

void activity_tie2(void);

void activity_ti4(PORT_TIMER_WIDTH capturedTime);

void activity_tie3(void);

void activity_ti5(PORT_TIMER_WIDTH capturedTime);

void activity_ti6(void);

void activity_tie4(void);

void activity_ti7(void);

void activity_tie5(void);

void activity_ti8(PORT_TIMER_WIDTH capturedTime);

void activity_tie6(void);

void activity_ti9(PORT_TIMER_WIDTH capturedTime);

// RX
void activity_ri2(void);

void activity_rie1(void);

void activity_ri3(void);

void activity_rie2(void);

void activity_ri4(PORT_TIMER_WIDTH capturedTime);

void activity_rie3(void);

void activity_ri5(PORT_TIMER_WIDTH capturedTime);

void activity_ri6(void);

void activity_rie4(void);

void activity_ri7(void);

void activity_rie5(void);

void activity_ri8(PORT_TIMER_WIDTH capturedTime);

void activity_rie6(void);

void activity_ri9(PORT_TIMER_WIDTH capturedTime);

// frame validity check
bool isValidRxFrame(ieee802154_header_iht *ieee802514_header);

bool isValidAck(ieee802154_header_iht *ieee802514_header, OpenQueueEntry_t *packetSent);

bool isValidJoin(OpenQueueEntry_t *eb, ieee802154_header_iht *parsedHeader);

bool isValidEbFormat(OpenQueueEntry_t *pkt, uint16_t *lenIE);

// IEs Handling
bool ieee154e_processIEs(OpenQueueEntry_t *pkt, uint16_t *lenIE);

void timeslotTemplateIDStoreFromEB(uint8_t id);

void channelhoppingTemplateIDStoreFromEB(uint8_t id);

// ASN handling
void incrementAsnOffset(void);

void ieee154e_resetAsn(void);

void ieee154e_syncSlotOffset(void);

void asnStoreFromEB(uint8_t *asn);

void joinPriorityStoreFromEB(uint8_t jp);

// synchronization
// receiver son use syncpkt, sender son use syncack
void synchronizePacket(PORT_TIMER_WIDTH timeReceived);

void synchronizeAck(PORT_SIGNED_INT_WIDTH timeCorrection);

void changeIsSync(bool newIsSync);

// notifying upper layer
void notif_sendDone(OpenQueueEntry_t *packetSent, owerror_t error);

void notif_receive(OpenQueueEntry_t *packetReceived);

// statistics
void resetStats(void);

void updateStats(PORT_SIGNED_INT_WIDTH timeCorrection);

// misc
uint8_t calculateFrequency(uint8_t channelOffset);

void changeState(ieee154e_state_t newstate);

void endSlot(void);

bool debugPrint_asn(void);

bool debugPrint_isSync(void);

// interrupts
void isr_ieee154e_newSlot(opentimers_id_t id);

void isr_ieee154e_timer(opentimers_id_t id);

void isr_ieee154e_inhibitStart(opentimers_id_t id);

//=========================== admin ===========================================

/**
\brief This function initializes this module.

Call this function once before any other function in this module, possibly
during boot-up.
*/
void ieee154e_init(void) {

    // initialize variables
    memset(&ieee154e_vars, 0, sizeof(ieee154e_vars_t));
    memset(&ieee154e_dbg, 0, sizeof(ieee154e_dbg_t));

    // set singleChannel to 0 to enable channel hopping.
#if IEEE802154E_SINGLE_CHANNEL
    ieee154e_vars.singleChannel     = IEEE802154E_SINGLE_CHANNEL;
#else
    ieee154e_vars.singleChannel = 0; // 0 means channel hopping
#endif
    ieee154e_vars.isAckEnabled = TRUE;
    ieee154e_vars.isSecurityEnabled = FALSE;
    ieee154e_vars.slotDuration = TsSlotDuration;
    ieee154e_vars.numOfSleepSlots = 1;

    // default hopping template
    memcpy(&(ieee154e_vars.chTemplate[0]), chTemplate_default, sizeof(ieee154e_vars.chTemplate));

    if (idmanager_getIsDAGroot() == TRUE) {
        changeIsSync(TRUE);
    } else {
        changeIsSync(FALSE);
    }

    resetStats();
    ieee154e_stats.numDeSync = 0;

    // switch radio on
    radio_rfOn();

#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#endif
    radio_setStartFrameCb(ieee154e_startOfFrame);
    radio_setEndFrameCb(ieee154e_endOfFrame);
    // have the radio start its timer and assign ieee802154e timer with highest priority
    ieee154e_vars.timerId = opentimers_create(TIMER_TSCH, TASKPRIO_NONE);
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,          // timerId
            ieee154e_vars.slotDuration,     // duration
            sctimer_readCounter(),          // reference
            TIME_TICS,                      // timetype
            isr_ieee154e_newSlot            // callback
    );
    IEEE802154_security_init();
    ieee154e_vars.serialInhibitTimerId = opentimers_create(TIMER_INHIBIT, TASKPRIO_NONE);
}

//=========================== public ==========================================

/**
/brief Difference between some older ASN and the current ASN.

\param[in] someASN some ASN to compare to the current

\returns The ASN difference, or 0xffff if more than 65535 different
*/
PORT_TIMER_WIDTH ieee154e_asnDiff(asn_t *someASN) {
    PORT_TIMER_WIDTH diff;
    INTERRUPT_DECLARATION();
    DISABLE_INTERRUPTS();
    if (ieee154e_vars.asn.byte4 != someASN->byte4) {
        ENABLE_INTERRUPTS();
        return (PORT_TIMER_WIDTH) 0xFFFFFFFF;;
    }

    diff = 0;
    if (ieee154e_vars.asn.bytes2and3 == someASN->bytes2and3) {
        ENABLE_INTERRUPTS();
        return ieee154e_vars.asn.bytes0and1 - someASN->bytes0and1;
    } else if (ieee154e_vars.asn.bytes2and3 - someASN->bytes2and3 == 1) {
        diff = ieee154e_vars.asn.bytes0and1;
        diff += 0xffff - someASN->bytes0and1;
        diff += 1;
    } else {
        diff = (PORT_TIMER_WIDTH) 0xFFFFFFFF;;
    }
    ENABLE_INTERRUPTS();
    return diff;
}

#if DEADLINE_OPTION
/**
/brief Difference between two ASN values

\param[in] h_asn bigger ASN value
\param[in] l_asn smaller ASN value

\returns The ASN difference, or 0xffff if more than 65535 different
*/
int16_t ieee154e_computeAsnDiff(asn_t *h_asn, asn_t *l_asn) {
    int16_t diff;

    if (h_asn->byte4 != l_asn->byte4) {
        return (int16_t) 0xFFFFFFFF;
    }

    diff = 0;
    if (h_asn->bytes2and3 == l_asn->bytes2and3) {
        return h_asn->bytes0and1 - l_asn->bytes0and1;
    } else if (h_asn->bytes2and3 - l_asn->bytes2and3 == 1) {
        diff = h_asn->bytes0and1;
        diff += 0xffff - l_asn->bytes0and1;
        diff += 1;
    } else {
        diff = (int16_t) 0xFFFFFFFF;
    }
    return diff;
}

/**
/brief Determine Expiration Time in ASN

\param[in]  max_delay Maximum permissible delay before which
            packet is expected to reach destination

\param[out] et_asn bigger ASN value
*/
void ieee154e_calculateExpTime(uint16_t max_delay, uint8_t *et_asn) {
    uint8_t delay_array[5];
    uint8_t i = 0, carry = 0, slot_time = 0;
    uint16_t sum = 0, delay_in_asn = 0;

    memset(&delay_array[0], 0, 5);

    //Slot time = (Duration in ticks * Time equivalent ticks w.r.t 32kHz) in ms
    slot_time = (ieee154e_getSlotDuration() * 305) / 10000;
    delay_in_asn = max_delay / slot_time;

    delay_array[0] = (delay_in_asn & 0xff);
    delay_array[1] = (delay_in_asn / 256 & 0xff);

    ieee154e_getAsn(&et_asn[0]);
    for (i = 0; i < 5; i++) {
        sum = et_asn[i] + delay_array[i] + carry;
        et_asn[i] = sum & 0xFF;
        carry = ((sum >> 8) & 0xFF);
    }
}

/**
/brief Format asn to asn_t structure

\param[in]  in  asn value represented in array format

\param[out] val_asn   asn value represented in asn_t format
*/

#endif
void ieee154e_orderToASNStructure(uint8_t *in, asn_t *val_asn) {
    val_asn->bytes0and1 = in[0] + 256 * in[1];
    val_asn->bytes2and3 = in[2] + 256 * in[3];
    val_asn->byte4 = in[4];
}
//======= events

/**
\brief Indicates a new slot has just started.

This function executes in ISR mode, when the new slot timer fires.
*/
void isr_ieee154e_newSlot(opentimers_id_t id) {

    ieee154e_vars.startOfSlotReference = opentimers_getCurrentCompareValue();
    leds_sync_toggle();
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                  // timerId
            TsSlotDuration,                         // duration
            ieee154e_vars.startOfSlotReference,     // reference
            TIME_TICS,                              // timetype
            isr_ieee154e_newSlot                    // callback
    );
    ieee154e_vars.slotDuration = TsSlotDuration;

    if (ieee154e_vars.isSync == FALSE) {
        if (idmanager_getIsDAGroot() == TRUE) {
            changeIsSync(TRUE);
            ieee154e_resetAsn();
            ieee154e_vars.nextActiveSlotOffset = schedule_getNextActiveSlotOffset();
        } else {
            //防止鸡生蛋问题：mac初始化在centerschedule之前，而需要下面这个函数需要role的信息，由于调用次数很少，没必要新增参数。
            //if(center_vars.role >= CENTER_ROLE_LEADER)
                activity_synchronize_newSlot();
        }
    } else {
#if OPENWSN_ADAPTIVE_SYNC_C
        // adaptive synchronization
        adaptive_sync_countCompensationTimeout();
#endif
        activity_ti1ORri1();
    }
    ieee154e_dbg.num_newSlot++;
}

/**
\brief Indicates the FSM timer has fired.

This function executes in ISR mode, when the FSM timer fires.
*/
void isr_ieee154e_timer(opentimers_id_t id) {
    switch (ieee154e_vars.state) {
        case S_TXDATAOFFSET:
            activity_ti2();
            break;
        case S_TXDATAPREPARE:
            activity_tie1();
            break;
        case S_TXDATAREADY:
            activity_ti3();
            break;
        case S_TXDATADELAY:
            activity_tie2();
            break;
        case S_TXDATA:
            activity_tie3();
            break;
        case S_RXACKOFFSET:
            activity_ti6();
            break;
        case S_RXACKPREPARE:
            activity_tie4();
            break;
        case S_RXACKREADY:
            activity_ti7();
            break;
        case S_RXACKLISTEN:
            activity_tie5();
            break;
        case S_RXACK:
            activity_tie6();
            break;
        case S_RXDATAOFFSET:
            activity_ri2();
            break;
        case S_RXDATAPREPARE:
            activity_rie1();
            break;
        case S_RXDATAREADY:
            activity_ri3();
            break;
        case S_RXDATALISTEN:
            activity_rie2();
            break;
        case S_RXDATA:
            activity_rie3();
            break;
        case S_TXACKOFFSET:
            activity_ri6();
            break;
        case S_TXACKPREPARE:
            activity_rie4();
            break;
        case S_TXACKREADY:
            activity_ri7();
            break;
        case S_TXACKDELAY:
            activity_rie5();
            break;
        case S_TXACK:
            activity_rie6();
            break;
        case S_SYNCRX:
            break;
        default:
            // log the error
            LOG_CRITICAL(COMPONENT_IEEE802154E, ERR_WRONG_STATE_IN_TIMERFIRES,
                         (errorparameter_t) ieee154e_vars.state,
                         (errorparameter_t) ieee154e_vars.slotOffset);
            // abort
            endSlot();
            break;
    }
    ieee154e_dbg.num_timer++;
}

/**
\brief Inhibit the serial activity.

This needs to happen

This function executes in ISR mode.
*/
void isr_ieee154e_inhibitStart(opentimers_id_t id) {
    // inhibit serial activity
    //openserial_leader_printf("openserial_inhibitStart"); 
    openserial_inhibitStart(); // activity_inhibitSerial
}

/**
\brief Indicates the radio just received the first byte of a packet.

This function executes in ISR mode.
*/
void ieee154e_startOfFrame(PORT_TIMER_WIDTH capturedTime) {
    //openserial_root_printf("startoframe");

    if(ieee154e_vars.dataToSend->creator == COMPONENT_CENTER_SCHEDULE){
        //openserial_mysf_printf("unicast: ieee154e_startOfFrame");
    }
    //openserial_leader_printf("EB/KA: ieee154e_startOfFrame");
    if(schedule_getType()==CELLTYPE_RX){
        #ifdef DEBUG_ROOT_RX
        openserial_root_printf("rx:ieee154e_startOfFrame");
        #endif
    }
    PORT_TIMER_WIDTH referenceTime = capturedTime - ieee154e_vars.startOfSlotReference;
    if (ieee154e_vars.isSync == FALSE) {
        activity_synchronize_startOfFrame(referenceTime);
    } else {
        switch (ieee154e_vars.state) {
            case S_TXDATADELAY:
                activity_ti4(referenceTime);
                break;
            case S_RXACKREADY:
                /*
                It is possible to receive in this state for radio where there is no way of differentiated between
                "ready to listen" and "listening" (e.g. CC2420). We must therefore expect to the start of a packet in
                this "ready" state.
                 */
                // no break!
            case S_RXACKLISTEN:
                activity_ti8(referenceTime);
                break;
            case S_RXDATAREADY:
                /* Similarly as above. */
                // no break!
            case S_RXDATALISTEN:
                activity_ri4(referenceTime);
                break;
            case S_TXACKDELAY:
                activity_ri8(referenceTime);
                break;
            default:
                // log the error
                LOG_ERROR(COMPONENT_IEEE802154E, ERR_WRONG_STATE_IN_NEWSLOT,
                          (errorparameter_t)ieee154e_vars.state,
                          (errorparameter_t)ieee154e_vars.slotOffset);
                // abort
                endSlot();
                break;
        }
    }
    ieee154e_dbg.num_startOfFrame++;
}

/**
\brief Indicates the radio just received the last byte of a packet.

This function executes in ISR mode.
*/
void ieee154e_endOfFrame(PORT_TIMER_WIDTH capturedTime) {
    #ifdef DEBUG_ROOT_RX
    // openserial_root_printf("rx:ieee154e_endOfFrame");
    // openserial_root_printf("endOfFrame: state=%d, slotOffset=%d, asn=%lu", 
    //                      ieee154e_vars.state,
    //                      ieee154e_vars.slotOffset,
    //                      ieee154e_vars.asn.byte4);
    // if(ieee154e_vars.dataReceived) {
    //     openserial_root_printf("rxLen=%d, lqi=%d, rssi=%d, crc=%d",
    //                          ieee154e_vars.dataReceived->length,
    //                          ieee154e_vars.dataReceived->l1_lqi,
    //                          ieee154e_vars.dataReceived->l1_rssi,
    //                          ieee154e_vars.dataReceived->l1_crc);
    // }
    // if(ieee154e_vars.dataToSend) {
    //     openserial_root_printf("txLen=%d, creator=%d",
    //                          ieee154e_vars.dataToSend->length,
    //                          ieee154e_vars.dataToSend->creator);
    // }
    #endif
    //openserial_root_printf("endoframe");
    //if(ieee154e_vars.dataToSend->creator == COMPONENT_CENTER_SCHEDULE)
        //openserial_mysf_printf("unicast: ieee154e_endOfFrame");
    //openserial_leader_printf("EB/KA: ieee154e_endOfFrame");
    PORT_TIMER_WIDTH referenceTime = capturedTime - ieee154e_vars.startOfSlotReference;
    if (ieee154e_vars.isSync == FALSE) {
        activity_synchronize_endOfFrame(referenceTime);
    } else {
        switch (ieee154e_vars.state) {
            case S_TXDATA:
                activity_ti5(referenceTime);
                break;
            case S_RXACK:
                activity_ti9(referenceTime);
                break;
            case S_RXDATA:
                activity_ri5(referenceTime);
                break;
            case S_TXACK:
                activity_ri9(referenceTime);
                break;
            default:
                // log the error
                LOG_ERROR(COMPONENT_IEEE802154E, ERR_WRONG_STATE_IN_ENDOFFRAME,
                          (errorparameter_t) ieee154e_vars.state,
                          (errorparameter_t) ieee154e_vars.slotOffset
                );
                // abort
                endSlot();
                break;
        }
    }
    ieee154e_dbg.num_endOfFrame++;
}

//======= misc

/**
\brief Trigger this module to print status information, over serial.

debugPrint_* functions are used by the openserial module to continuously print
status information about several modules in the OpenWSN stack.

\returns TRUE if this function printed something, FALSE otherwise.
*/
bool debugPrint_asn(void) {
    asn_t output;
    output.byte4 = ieee154e_vars.asn.byte4;
    output.bytes2and3 = ieee154e_vars.asn.bytes2and3;
    output.bytes0and1 = ieee154e_vars.asn.bytes0and1;
    openserial_printStatus(STATUS_ASN, (uint8_t * ) & output, sizeof(output));
    return TRUE;
}

/**
\brief Trigger this module to print status information, over serial.

debugPrint_* functions are used by the openserial module to continuously print
status information about several modules in the OpenWSN stack.

\returns TRUE if this function printed something, FALSE otherwise.
*/
bool debugPrint_isSync(void) {
    uint8_t output = 0;
    output = ieee154e_vars.isSync;
    openserial_printStatus(STATUS_ISSYNC, (uint8_t * ) & output, sizeof(uint8_t));
    return TRUE;
}

/**
\brief Trigger this module to print status information, over serial.

debugPrint_* functions are used by the openserial module to continuously print
status information about several modules in the OpenWSN stack.

\returns TRUE if this function printed something, FALSE otherwise.
*/
bool debugPrint_macStats(void) {
    // send current stats over serial
    openserial_printStatus(STATUS_MACSTATS, (uint8_t * ) & ieee154e_stats, sizeof(ieee154e_stats_t));
    return TRUE;
}

//=========================== private =========================================

//======= SYNCHRONIZING

port_INLINE void activity_synchronize_newSlot(void) {

    if(center_vars.role < CENTER_ROLE_LEADER){
        openserial_mysf_printf("sync,f1");
        return;
    }
    //openserial_leader_printf("activity_synchronize_newSlot");
    // I'm in the middle of receiving a packet
    if (ieee154e_vars.state == S_SYNCRX) {
        return;
    }

    ieee154e_vars.numOfnewSlot = ieee154e_dbg.num_newSlot;

    ieee154e_vars.radioOnInit = sctimer_readCounter();
    ieee154e_vars.radioOnThisSlot = TRUE;

    // if this is the first time I call this function while not synchronized,
    // switch on the radio in Rx mode
    if (ieee154e_vars.state != S_SYNCLISTEN) {
        // change state
        changeState(S_SYNCLISTEN);

        // turn off the radio (in case it wasn't yet)
        radio_rfOff();

        // update record of current channel
#if IEEE802154E_SINGLE_CHANNEL
        ieee154e_vars.freq = IEEE802154E_SINGLE_CHANNEL;
#else
#if CENTER_SCHEDULE
        switch(center_vars.role){
        case CENTER_ROLE_LEADER:
            ieee154e_vars.freq = calculateFrequency(SCHEDULE_MINIMAL_6TISCH_CHANNELOFFSET);
            break;
        case CENTER_ROLE_MEMBER:
            openserial_member_printf("listening channel: %d",SCHEDULE_MINIMAL_6TISCH_CHANNELOFFSET+MEMBER_EXPECTED_GROUP_ID + 1);
            ieee154e_vars.freq = calculateFrequency(SCHEDULE_MINIMAL_6TISCH_CHANNELOFFSET+MEMBER_EXPECTED_GROUP_ID + 1) ;
            break;
        }
#elif
        ieee154e_vars.freq = (openrandom_get16b() & 0x0F) + 11;
#endif

#endif

        // configure the radio to listen to the frequency
        radio_ble_setFrequency(ieee154e_vars.freq);

#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#endif

        // switch on the radio in Rx mode.
        radio_rxEnable();
        radio_rxNow();
    } else {
        // I have been listening since last slot
        ieee154e_stats.numTicsOn += ieee154e_vars.slotDuration;
        ieee154e_stats.numTicsTotal += ieee154e_vars.slotDuration;

#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#endif

        //每160个时隙更换一次监听信道
        //目的：让未同步节点能扫描所有信道，增加接收EB的机会
//         if (ieee154e_vars.asn.bytes0and1 % (NUM_CHANNELS * EB_PORTION) == 0) {
//             // turn off the radio (in case it wasn't yet)
//             radio_rfOff();

//             // update record of current channel
// #if IEEE802154E_SINGLE_CHANNEL
//             ieee154e_vars.freq = IEEE802154E_SINGLE_CHANNEL;
// #else
//             ieee154e_vars.freq = (openrandom_get16b() & 0x0F) + 11;
// #endif

//             // configure the radio to listen to the frequency
//             radio_ble_setFrequency(ieee154e_vars.freq);
//         }

        // switch on the radio in Rx mode.
        radio_rxEnable();
        radio_rxNow();
    }

    // if I'm already in S_SYNCLISTEN, while not synchronized, but the synchronizing channel has been changed, change
    // the synchronizing channel
    if ((ieee154e_vars.state == S_SYNCLISTEN) && (ieee154e_vars.singleChannelChanged == TRUE)) {
        // turn off the radio (in case it wasn't yet)
        radio_rfOff();

        // update record of current channel
        ieee154e_vars.freq = calculateFrequency(ieee154e_vars.singleChannel);

        openserial_member_printf("chan change");
        // configure the radio to listen to the default synchronizing channel
        radio_ble_setFrequency(ieee154e_vars.freq);

#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#endif

        // switch on the radio in Rx mode.
        radio_rxEnable();
        radio_rxNow();
        ieee154e_vars.singleChannelChanged = FALSE;
    }
    // increment dummy ASN to trigger debugprint every now and then
    ieee154e_vars.asn.bytes0and1++;

    opentimers_scheduleAbsolute(
            ieee154e_vars.serialInhibitTimerId,     // timerId
            DURATION_si,                            // duration
            ieee154e_vars.startOfSlotReference,     // reference
            TIME_TICS,                              // timetype
            isr_ieee154e_inhibitStart               // callback
    );

    //openserial_leader_printf("openserial_inhibitStop"); 
    openserial_inhibitStop();
}

port_INLINE void activity_synchronize_startOfFrame(PORT_TIMER_WIDTH capturedTime) {

    openserial_mysf_printf("activity_synchronize_startOfFrame");
    // don't care about packet if I'm not listening
    if (ieee154e_vars.state != S_SYNCLISTEN) {
        return;
    }

    // inhibit serial activity
    openserial_inhibitStart(); // synchronize start of frame

    // change state
    changeState(S_SYNCRX);
    // there is no action when the timer fired at S_SYNCRX.
    // hence the inhibit timer scheduled at beginning of slot won't be effected.

    // record the captured time
    ieee154e_vars.lastCapturedTime = capturedTime;

    // record the captured time (for sync)
    ieee154e_vars.syncCapturedTime = capturedTime;
}

port_INLINE void activity_synchronize_endOfFrame(PORT_TIMER_WIDTH capturedTime) {
    ieee802154_header_iht ieee802514_header;
    uint16_t lenIE;
    openserial_mysf_printf("activity_synchronize_endOfFrame");
    // check state
    if (ieee154e_vars.state != S_SYNCRX) {
        // log the error
        LOG_ERROR(COMPONENT_IEEE802154E, ERR_WRONG_STATE_IN_ENDFRAME_SYNC,
                  (errorparameter_t) ieee154e_vars.state,
                  (errorparameter_t) 0);
        // abort
        return;
    }

    // change state
    changeState(S_SYNCPROC);
    openserial_member_printf("S_SYNCPROC");

    // get a buffer to put the (received) frame in
    ieee154e_vars.dataReceived = openqueue_getFreePacketBuffer(COMPONENT_IEEE802154E);
    if (ieee154e_vars.dataReceived == NULL) {
        LOG_ERROR(COMPONENT_IEEE802154E, ERR_NO_FREE_PACKET_BUFFER, (errorparameter_t) 0, (errorparameter_t) 0);
        // abort
        return;
    }

    // declare ownership over that packet
    ieee154e_vars.dataReceived->creator = COMPONENT_IEEE802154E;
    ieee154e_vars.dataReceived->owner = COMPONENT_IEEE802154E;

    /*
    The do-while loop that follows is a little parsing trick. It contains a while(0) condition, but it gets executed
    only once. The behavior is:
    - if a break occurs inside the do{} body, the error code below the loop
      gets executed. This indicates something is wrong with the packet being
      parsed.
    - if a return occurs inside the do{} body, the error code below the loop
      does not get executed. This indicates the received packet is correct.
    */
    do { // this "loop" is only executed once
        // retrieve the received data frame from the radio's Rx buffer
        ieee154e_vars.dataReceived->payload = &(ieee154e_vars.dataReceived->packet[FIRST_FRAME_BYTE]);
        radio_ble_getReceivedFrame(ieee154e_vars.dataReceived->payload,
                               (uint8_t * ) & ieee154e_vars.dataReceived->length,
                               sizeof(ieee154e_vars.dataReceived->packet),
                               &ieee154e_vars.dataReceived->l1_rssi,
                               &ieee154e_vars.dataReceived->l1_lqi,
                               &ieee154e_vars.dataReceived->l1_crc);
        openserial_leader_printf("datalen:%d",ieee154e_vars.dataReceived->length);
        // break if packet too short
        if (//ieee154e_vars.dataReceived->length < LENGTH_CRC ||
            ieee154e_vars.dataReceived->length > LENGTH_IEEE154_MAX) {
            // break from the do-while loop and execute abort code below

            LOG_ERROR(COMPONENT_IEEE802154E, ERR_INVALID_PACKET_FROM_RADIO,
                      (errorparameter_t) 0,
                      ieee154e_vars.dataReceived->length);
            break;
        }

        // toss CRC (2 last bytes)
        // packetfunctions_tossFooter(&ieee154e_vars.dataReceived, LENGTH_CRC);

        // break if invalid CRC
        if (ieee154e_vars.dataReceived->l1_crc == FALSE) {
            // break from the do-while loop and execute abort code below
            openserial_leader_printf("crc==false");
            break;
        }

        // parse the IEEE802.15.4 header (synchronize, end of frame)
        ieee802154_retrieveHeader(ieee154e_vars.dataReceived, &ieee802514_header);
        

        // break if invalid IEEE802.15.4 header
        if (ieee802514_header.valid == FALSE) {
            openserial_member_printf("header.valid == FALSE");
            openserial_leader_printf("header.valid == FALSE");
            // break from the do-while loop and execute the clean-up code below
            break;
        }

        // store header details in packet buffer
        ieee154e_vars.dataReceived->l2_frameType = ieee802514_header.frameType;
        ieee154e_vars.dataReceived->l2_dsn = ieee802514_header.dsn;
        memcpy(&(ieee154e_vars.dataReceived->l2_nextORpreviousHop), &(ieee802514_header.src), sizeof(open_addr_t));

        // verify that incoming security level is acceptable
        if (IEEE802154_security_acceptableLevel(ieee154e_vars.dataReceived, &ieee802514_header) == FALSE) {
            openserial_member_printf("GG here0");
            openserial_leader_printf("GG here0");
            break;
        }

        // 如果安全级别不是无安全级别，则需要解析IEs和获取ASN，
        // 因为nonce是基于ASN创建的，
        // 所以，在认证beacon之前，需要先解析IEs和获取ASN。
        // 调用sixtop_send的l2_securityLevel会被设置为IEEE154_ASH_SLF_TYPE_NOSEC
        if (ieee154e_vars.dataReceived->l2_securityLevel != IEEE154_ASH_SLF_TYPE_NOSEC) {
            // If we are not synced, we need to parse IEs and retrieve the ASN
            // before authenticating the beacon, because nonce is created from the ASN
            if (!ieee154e_vars.isSync && ieee802514_header.frameType == IEEE154_TYPE_BEACON) {
                if (!isValidJoin(ieee154e_vars.dataReceived, &ieee802514_header)) {
                    openserial_member_printf("not valid join");
                    openserial_leader_printf("not valid join");
                    break;
                }
            } else { // discard other frames as we cannot decrypt without being synced
                openserial_member_printf("here2");
                openserial_leader_printf("here2");
                break;
            }
        }

        // toss the IEEE802.15.4 header -- this does not include IEs as they are processed
        // next.
        packetfunctions_tossHeader(&ieee154e_vars.dataReceived, ieee802514_header.headerLength);

        // process IEs
        lenIE = 0;
        if (
                (
                        ieee802514_header.valid == TRUE &&
                        ieee802514_header.ieListPresent == TRUE &&
                        ieee802514_header.frameType == IEEE154_TYPE_BEACON &&
                        packetfunctions_sameAddress(&ieee802514_header.panid, idmanager_getMyID(ADDR_PANID)) &&
                        ieee154e_processIEs(ieee154e_vars.dataReceived, &lenIE)
                ) == FALSE) {
            openserial_member_printf("GG here");
            openserial_member_printf("%d%d%d%d",ieee802514_header.valid,ieee802514_header.ieListPresent,ieee802514_header.frameType,(uint8_t)packetfunctions_sameAddress(&ieee802514_header.panid, idmanager_getMyID(ADDR_PANID)));
            openserial_leader_printf("GG here");
            openserial_leader_printf("%d%d%d%d",ieee802514_header.valid,ieee802514_header.ieListPresent,ieee802514_header.frameType,(uint8_t)packetfunctions_sameAddress(&ieee802514_header.panid, idmanager_getMyID(ADDR_PANID)));
            // break from the do-while loop and execute the clean-up code below
            break;
        }

        // turn off the radio
        radio_rfOff();

        // compute radio duty cycle
        ieee154e_vars.radioOnTics += (sctimer_readCounter() - ieee154e_vars.radioOnInit);

        // toss the IEs
        packetfunctions_tossHeader(&ieee154e_vars.dataReceived, lenIE);

        // synchronize (for the first time) to the sender's EB
        synchronizePacket(ieee154e_vars.syncCapturedTime);
        openserial_mysf_printf("EB: synchronize (first time) to sender, id:%d",ieee154e_vars.dataReceived->l2_nextORpreviousHop.addr_64b[7]);

        // declare synchronized
        changeIsSync(TRUE);
        // log the info
        LOG_SUCCESS(COMPONENT_IEEE802154E, ERR_SYNCHRONIZED,
                (errorparameter_t) ieee154e_vars.slotOffset,
                (errorparameter_t) 0);

        // send received EB up the stack so RES can update statistics (synchronizing)
        notif_receive(ieee154e_vars.dataReceived);

        // clear local variable
        ieee154e_vars.dataReceived = NULL;

        // official end of synchronization
        endSlot();

        // everything went well, return here not to execute the error code below
        return;

    } while (0);

    // free the (invalid) received data buffer so RAM memory can be recycled
    openqueue_freePacketBuffer(ieee154e_vars.dataReceived);

    // clear local variable
    ieee154e_vars.dataReceived = NULL;

    // return to listening state
    changeState(S_SYNCLISTEN);
}

port_INLINE bool ieee154e_processIEs(OpenQueueEntry_t* pkt, uint16_t* lenIE) {
    uint8_t i;
    if (isValidEbFormat(pkt, lenIE) == TRUE){
        // At this point, ASN and frame length are known and the current slotoffset can be inferred
        ieee154e_syncSlotOffset();
        schedule_syncSlotOffset(ieee154e_vars.slotOffset);
        ieee154e_vars.nextActiveSlotOffset = schedule_getNextActiveSlotOffset();

        /* infer the asnOffset based on the fact that ieee154e_vars.freq = 11 + (asnOffset + channelOffset)%16 */
        for (i = 0; i < NUM_CHANNELS; i++){
            if ((ieee154e_vars.freq - 11) == ieee154e_vars.chTemplate[i]){
                break;
            }
        }
        ieee154e_vars.asnOffset = i - schedule_getChannelOffset();
        return TRUE;
    } else {
        // wrong eb format
        LOG_ERROR(COMPONENT_IEEE802154E, ERR_UNSUPPORTED_FORMAT, (errorparameter_t)3, (errorparameter_t)0);
        return FALSE;
    }
}

//======= TX

port_INLINE void activity_ti1ORri1(void) {
    cellType_t cellType;
    open_addr_t neighbor;
    uint8_t i;
    uint8_t asn[5];
    uint8_t join_priority;
    bool couldSendEB = FALSE;
    //openserial_leader_printf("activity_ti1ORri1"); 
    // increment ASN (do this first so debug pins are in sync)
    incrementAsnOffset();

    // wiggle debug pins
    debugpins_slot_toggle();
    if (ieee154e_vars.slotOffset == 0) {
        debugpins_frame_toggle();
    }

    // desynchronize if needed
    if (idmanager_getIsDAGroot() == FALSE) {
        if (ieee154e_vars.deSyncTimeout > ieee154e_vars.numOfSleepSlots) {
            ieee154e_vars.deSyncTimeout -= ieee154e_vars.numOfSleepSlots;
            //openserial_leader_printf("%d,%d",ieee154e_vars.deSyncTimeout,ieee154e_vars.asn.bytes0and1);
        } else {
            // Reset sleep slots
            //openserial_leader_printf("%d,%d",ieee154e_vars.slotOffset,ieee154e_vars.asn.bytes0and1);

            ieee154e_vars.numOfSleepSlots = 1;

            // declare myself desynchronized
            changeIsSync(FALSE);
            center_processDesync();
            openserial_leader_printf("Desync timeout");
            // log the error
            LOG_ERROR(COMPONENT_IEEE802154E, ERR_DESYNCHRONIZED,
                      (errorparameter_t)ieee154e_vars.slotOffset,
                      (errorparameter_t)ieee154e_vars.asn.bytes0and1);

            // update the statistics
            ieee154e_stats.numDeSync++;

            // abort
            endSlot();
            return;
        }
    }

    // 防止中断无限嵌套导致栈溢出：如果不是SLEEP状态，说明上一个时隙的操作还未完成就发生了超时
    // if the previous slot took too long, we will not be in the right state
    if (ieee154e_vars.state != S_SLEEP) {
        // log the error
        LOG_ERROR(COMPONENT_IEEE802154E, ERR_WRONG_STATE_IN_STARTSLOT,
                  (errorparameter_t) ieee154e_vars.state,
                  (errorparameter_t) ieee154e_vars.slotOffset);
        // abort
        endSlot();
        return;
    }

    // Reset sleep slots
    ieee154e_vars.numOfSleepSlots = 1;

    // update nextActiveSlotOffset before using
    ieee154e_vars.nextActiveSlotOffset = schedule_getNextActiveSlotOffset();
    if (ieee154e_vars.slotOffset == ieee154e_vars.nextActiveSlotOffset) {
        // this is the next active slot

        // advance the schedule
        schedule_advanceSlot();

        // calculate the frequency to transmit on
        ieee154e_vars.freq = calculateFrequency(schedule_getChannelOffset());

        // find the next one
        ieee154e_vars.nextActiveSlotOffset = schedule_getNextActiveSlotOffset();
        if (idmanager_getIsSlotSkip() && idmanager_getIsDAGroot() == FALSE) {
            if (ieee154e_vars.nextActiveSlotOffset > ieee154e_vars.slotOffset) {
                ieee154e_vars.numOfSleepSlots = ieee154e_vars.nextActiveSlotOffset - ieee154e_vars.slotOffset;
            } else {
                ieee154e_vars.numOfSleepSlots =
                        schedule_getFrameLength() + ieee154e_vars.nextActiveSlotOffset - ieee154e_vars.slotOffset;
            }

            opentimers_scheduleAbsolute(
                    ieee154e_vars.timerId,                            // timerId
                    TsSlotDuration * (ieee154e_vars.numOfSleepSlots),   // duration
                    ieee154e_vars.startOfSlotReference,               // reference
                    TIME_TICS,                                        // timetype
                    isr_ieee154e_newSlot                              // callback
            );

            //这里是关键，对于非根节点，它被设置为总是需要跳过非active-slot，用以节省能耗。
            //这里直接修改了slotDuration，以确保在睡眠期间结束后才会发生新的slot。
            //但这不影响当前的active-slot的行为。
            ieee154e_vars.slotDuration = TsSlotDuration * (ieee154e_vars.numOfSleepSlots);

            //increase ASN by numOfSleepSlots-1 slots as at this slot is already incremented by 1
            for (i = 0; i < ieee154e_vars.numOfSleepSlots - 1; i++) {
                incrementAsnOffset();
            }
        }
    } else {
        // this is NOT the next active slot, abort
        endSlot();
        return;
    }

    // check the schedule to see what type of slot this is
    cellType = schedule_getType();
    switch (cellType) {
        case CELLTYPE_TXRX:
        case CELLTYPE_TX_CMD:
        case CELLTYPE_TX:
            // assuming that there is nothing to send
            ieee154e_vars.dataToSend = NULL;
            // get the neighbor
            schedule_getNeighbor(&neighbor);

            // check whether we can send
            if (schedule_getOkToSend()) {//new_added
                if (packetfunctions_isBroadcastMulticast(&neighbor) == FALSE) {

                    // look for a unicast packet to send
                    ieee154e_vars.dataToSend = openqueue_macGetUnicastPacket(&neighbor);
                    // if(packetfunctions_isToRoot(&neighbor)){
                    //     ieee154e_vars.dataToSend = openqueue_getPacketByComponent(COMPONENT_LEADER_TO_ROOT);
                    // }else{
                    //     //移动节点也适用于该接口。
                    //     ieee154e_vars.dataToSend = openqueue_getPacketByComponent(COMPONENT_LEADER_TO_MEMBER);
                    // }
                    if(ieee154e_vars.dataToSend->creator == COMPONENT_CENTER_SCHEDULE
                        && ieee154e_vars.dataToSend->l2_nextORpreviousHop.addr_64b[7] != ROOT_ID){
                        #if DEBUG_MACTEST
                        mac_test_pkt_t* testPkt = (mac_test_pkt_t*)&ieee154e_vars.dataToSend->l2_payload[2];
                        openserial_root_printf("pkt got, dsn: %d, to group %d target %d", 
                                            testPkt->groupId,
                                            testPkt->targetId,
                                            ieee154e_vars.dataToSend->l2_dsn);
                        #endif
                        openserial_root_printf("slotoffset:%d, channel:%d",schedule_getSlottOffset(),schedule_getChannelOffset());
                    }
                    if (ieee154e_vars.dataToSend == NULL) {
                        ieee154e_vars.dataToSend = openqueue_macGetKaPacket(&neighbor);
                        //openserial_leader_printf("KA sending: slotoffset:%d, channel:%d",schedule_getSlottOffset(),schedule_getChannelOffset());
                        
                    }

                    if (schedule_getShared() == FALSE) {
                        // update numCellElapsed and numCellUsed on managed Tx cell
                        if (ieee154e_vars.dataToSend != NULL) {
                            ieee154e_vars.dataToSend->l2_sendOnTxCell = TRUE;
                            //msf_updateCellsUsed(&neighbor, CELLTYPE_TX);
                        }
                        //msf_updateCellsElapsed(&neighbor, CELLTYPE_TX);
                    }
                } else {
                    // this is minimal cell
                    ieee154e_vars.dataToSend = openqueue_macGetDIOPacket();
                    if (ieee154e_vars.dataToSend == NULL) {
                        couldSendEB = TRUE;
                        // look for an EB packet in the queue
                        switch (center_vars.role)
                        {
                        case CENTER_ROLE_ROOT:
                            ieee154e_vars.dataToSend = openqueue_macGetEBPacket();
                            break;
                        case CENTER_ROLE_LEADER:
                            if(schedule_getSlottOffset() == center_vars.ebSlot 
                                && schedule_getChannelOffset() == center_vars.ebChannel
                                 & isOkToSendEB()){
                                ieee154e_vars.dataToSend = openqueue_macGetEBPacket();
                            }else{//组内资源广播
                                couldSendEB = FALSE;
                                ieee154e_vars.dataToSend = openqueue_macGetBroadcastPacket();
                            }
                            break;
                        case CENTER_ROLE_MEMBER:
                            break;
                        default:
                            ieee154e_vars.dataToSend = openqueue_macGetEBPacket();
                            break;
                        }

                    }
                }
            }

            if (ieee154e_vars.dataToSend == NULL) {
                if (cellType == CELLTYPE_TX) {
                    // abort
                    endSlot();
                    break;
                }
            } else {
                // change state
                changeState(S_TXDATAOFFSET);
                // change owner
                ieee154e_vars.dataToSend->owner = COMPONENT_IEEE802154E;
                if (couldSendEB == TRUE) { // I will be sending an EB copy synch IE -- should be Little endian?
                    // fill in the ASN field of the EB
                    ieee154e_getAsn(asn);
                    join_priority = (icmpv6rpl_getMyDAGrank() / MINHOPRANKINCREASE) - 1; //poipoi -- use dagrank(rank)-1
                    memcpy(ieee154e_vars.dataToSend->l2_ASNpayload, &asn[0], sizeof(asn_t));
                    memcpy(ieee154e_vars.dataToSend->l2_ASNpayload + sizeof(asn_t), &join_priority, sizeof(uint8_t));
                }
                // record that I attempt to transmit this packet
                ieee154e_vars.dataToSend->l2_numTxAttempts++;
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
                // arm tt1
                opentimers_scheduleAbsolute(
                        ieee154e_vars.timerId,                            // timerId
                        DURATION_tt1,                                     // duration
                        ieee154e_vars.startOfSlotReference,               // reference
                        TIME_TICS,                                        // timetype
                        isr_ieee154e_timer                                // callback
                );
#endif
                break;
            }
        case CELLTYPE_RX:
            // change state
            changeState(S_RXDATAOFFSET);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT

#else
            // arm rt1
            opentimers_scheduleAbsolute(
                    ieee154e_vars.timerId,                            // timerId
                    DURATION_rt1,                                     // duration
                    ieee154e_vars.startOfSlotReference,               // reference
                    TIME_TICS,                                        // timetype
                    isr_ieee154e_timer                                // callback
            );
#endif

            break;
        case CELLTYPE_TEMP:
            endSlot();
            break;
        default:

            // log the error
            LOG_CRITICAL(COMPONENT_IEEE802154E, ERR_WRONG_CELLTYPE,
                         (errorparameter_t) cellType,
                         (errorparameter_t) ieee154e_vars.slotOffset);
            // abort
            endSlot();
            break;

    }
}

port_INLINE void activity_ti2(void) {

    // change state
    changeState(S_TXDATAPREPARE);

#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm tt2
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_tt2,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );
    // make a local copy of the frame
    packetfunctions_duplicatePacket(&ieee154e_vars.localCopyForTransmission, ieee154e_vars.dataToSend);

    // check if packet needs to be encrypted/authenticated before transmission
    if (ieee154e_vars.localCopyForTransmission.l2_securityLevel != IEEE154_ASH_SLF_TYPE_NOSEC) { // security enabled
        // encrypt in a local copy
        if (IEEE802154_security_outgoingFrameSecurity(&ieee154e_vars.localCopyForTransmission) != E_SUCCESS) {
            // keep the frame in the OpenQueue in order to retry later
            endSlot(); // abort
            return;
        }
    }

    // add 2 CRC bytes only to the local copy as we end up here for each retransmission

    OpenQueueEntry_t* localCopy;
    localCopy = &ieee154e_vars.localCopyForTransmission;
    //ble未设置CRCINC（LEN长度包含CRC）则不需要预留
    // if (packetfunctions_reserveFooter(&localCopy, 2) == E_FAIL){
    //     // packet too big, will never successfully be transmitted, drop immediately
    //     // set retries to 1, so after it get decremented in endSlot, we drop the packet
    //     ieee154e_vars.dataToSend->l2_retriesLeft = 1;
    //     endSlot();
    //     return;
    // }

    // configure the radio to listen to the default synchronizing channel
    radio_ble_setFrequency(ieee154e_vars.freq);

    // load the packet in the radio's Tx buffer
    radio_ble_loadPacket(ieee154e_vars.localCopyForTransmission.payload, ieee154e_vars.localCopyForTransmission.length);
#endif
    // enable the radio in Tx mode. This does not send the packet.
    radio_txEnable();

    ieee154e_vars.radioOnInit = sctimer_readCounter();
    ieee154e_vars.radioOnThisSlot = TRUE;
    // change state
    changeState(S_TXDATAREADY);
}

port_INLINE void activity_tie1(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_MAXTXDATAPREPARE_OVERFLOW,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);
    // abort
    endSlot();
}

port_INLINE void activity_ti3(void) {
    // change state
    changeState(S_TXDATADELAY);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm tt3
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_tt3,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );

    // give the 'go' to transmit
    radio_txNow();
#endif
}

port_INLINE void activity_tie2(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_WDRADIO_OVERFLOWS,
              (errorparameter_t)ieee154e_vars.state,
              (errorparameter_t)ieee154e_vars.slotOffset);

    // abort
    endSlot();
}

//start of frame interrupt
port_INLINE void activity_ti4(PORT_TIMER_WIDTH capturedTime) {
    // change state
    changeState(S_TXDATA);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // cancel tt3
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            ieee154e_vars.slotDuration,                       // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
#endif
    // record the captured time
    ieee154e_vars.lastCapturedTime = capturedTime;
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm tt4
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_tt4,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );
#endif
}

port_INLINE void activity_tie3(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_WDDATADURATION_OVERFLOWS,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);

    // abort
    endSlot();
}

port_INLINE void activity_ti5(PORT_TIMER_WIDTH capturedTime) {
    bool listenForAck;

    // change state
    changeState(S_RXACKOFFSET);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // cancel tt4
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            ieee154e_vars.slotDuration,                       // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
#endif
    // turn off the radio
    radio_rfOff();
    ieee154e_vars.radioOnTics += (sctimer_readCounter() - ieee154e_vars.radioOnInit);

    // record the captured time
    ieee154e_vars.lastCapturedTime = capturedTime;

    // decides whether to listen for an ACK
    if (packetfunctions_isBroadcastMulticast(&ieee154e_vars.dataToSend->l2_nextORpreviousHop) == TRUE) {
        listenForAck = FALSE;
    } else {
        listenForAck = TRUE;
    }

    if (listenForAck == TRUE) {
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
        // arm tt5
        opentimers_scheduleAbsolute(
                ieee154e_vars.timerId,                            // timerId
                DURATION_tt5,                                     // duration
                ieee154e_vars.startOfSlotReference,               // reference
                TIME_TICS,                                        // timetype
                isr_ieee154e_timer                                // callback
        );
#endif
    } else {
        // indicate succesful Tx to schedule to keep statistics
        schedule_indicateTx(&ieee154e_vars.asn, TRUE);
        //openserial_root_printf("ti5:notif_sendDone");
        // indicate to upper later the packet was sent successfully
        notif_sendDone(ieee154e_vars.dataToSend, E_SUCCESS);
        // reset local variable
        ieee154e_vars.dataToSend = NULL;

        // abort
        endSlot();
    }
}

port_INLINE void activity_ti6(void) {
    //openserial_mysf_printf("activity_ti6: waiting for ack");
    // change state
    changeState(S_RXACKPREPARE);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm tt6
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_tt6,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );

    // configure the radio to listen to the default synchronizing channel
    radio_ble_setFrequency(ieee154e_vars.freq);

    radio_rxEnable();
#endif
    //caputre init of radio for duty cycle calculation
    ieee154e_vars.radioOnInit = sctimer_readCounter();
    ieee154e_vars.radioOnThisSlot = TRUE;

    // change state
    changeState(S_RXACKREADY);
}

port_INLINE void activity_tie4(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_MAXRXACKPREPARE_OVERFLOWS,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);
    // abort
    endSlot();
}

port_INLINE void activity_ti7(void) {
    // change state
    changeState(S_RXACKLISTEN);

    // start listening
    radio_rxNow();
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm tt7
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_tt7,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );
#endif
}

port_INLINE void activity_tie5(void) {
    openserial_mysf_printf("activity_tie5, ack waiting timeout!");
    // indicate transmit failed to schedule to keep stats
    schedule_indicateTx(&ieee154e_vars.asn, FALSE);

    // decrement transmits left counter
    ieee154e_vars.dataToSend->l2_retriesLeft--;
    openserial_mysf_printf("retry left: %d",ieee154e_vars.dataToSend->l2_retriesLeft);

    if (ieee154e_vars.dataToSend->l2_retriesLeft == 0) {
        // indicate tx fail if no more retries left
        openserial_root_printf("ti5e:notif_sendDone");

        notif_sendDone(ieee154e_vars.dataToSend, E_FAIL);
    } else {
        // return packet to the virtual COMPONENT_SIXTOP_TO_IEEE802154E component
        ieee154e_vars.dataToSend->owner = COMPONENT_SIXTOP_TO_IEEE802154E;
    }

    // reset local variable
    ieee154e_vars.dataToSend = NULL;

    // abort
    endSlot();
}

port_INLINE void activity_ti8(PORT_TIMER_WIDTH capturedTime) {
    // change state
    changeState(S_RXACK);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // cancel tt7
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            ieee154e_vars.slotDuration,                       // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
#endif
    // record the captured time
    ieee154e_vars.lastCapturedTime = capturedTime;
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm tt8
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_tt8,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );
#endif
}

port_INLINE void activity_tie6(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_WDACKDURATION_OVERFLOWS,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);
    // abort
    endSlot();
}

port_INLINE void activity_ti9(PORT_TIMER_WIDTH capturedTime) {
    ieee802154_header_iht ieee802514_header;

    // change state
    changeState(S_TXPROC);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // cancel tt8
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            ieee154e_vars.slotDuration,                       // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
#endif
    // turn off the radio
    radio_rfOff();
    //compute tics radio on.
    ieee154e_vars.radioOnTics += (sctimer_readCounter() - ieee154e_vars.radioOnInit);

    // record the captured time
    ieee154e_vars.lastCapturedTime = capturedTime;

    // get a buffer to put the (received) ACK in
    ieee154e_vars.ackReceived = openqueue_getFreePacketBuffer(COMPONENT_IEEE802154E);
    if (ieee154e_vars.ackReceived == NULL) {
        // log the error
        LOG_ERROR(COMPONENT_IEEE802154E, ERR_NO_FREE_PACKET_BUFFER, (errorparameter_t) 0, (errorparameter_t) 0);
        // abort
        endSlot();
        return;
    }

    // declare ownership over that packet
    ieee154e_vars.ackReceived->creator = COMPONENT_IEEE802154E;
    ieee154e_vars.ackReceived->owner = COMPONENT_IEEE802154E;

    /*
    The do-while loop that follows is a little parsing trick. It contains a while(0) condition, which gets executed
    only once. Below the do-while loop is some code to cleans up the ack variable. Anywhere in the do-while loop,
    a break statement can be called to jump to the clean up code early. If the loop ends without a break, the received
    packet was correct. If it got aborted early (through a break), the packet was faulty.
    */
    do { // this "loop" is only executed once
        // retrieve the received ack frame from the radio's Rx buffer
        ieee154e_vars.ackReceived->payload = &(ieee154e_vars.ackReceived->packet[FIRST_FRAME_BYTE]);
        radio_ble_getReceivedFrame(
                ieee154e_vars.ackReceived->payload,
                (uint8_t * ) & ieee154e_vars.ackReceived->length,
                sizeof(ieee154e_vars.ackReceived->packet),
                &ieee154e_vars.ackReceived->l1_rssi,
                &ieee154e_vars.ackReceived->l1_lqi,
                &ieee154e_vars.ackReceived->l1_crc
        );

        // break if wrong length
        if (//ieee154e_vars.ackReceived->length < LENGTH_CRC || 
            ieee154e_vars.ackReceived->length > LENGTH_IEEE154_MAX) {
            // break from the do-while loop and execute the clean-up code below
            LOG_ERROR(COMPONENT_IEEE802154E, ERR_INVALID_PACKET_FROM_RADIO,
                      (errorparameter_t) 1,
                      ieee154e_vars.ackReceived->length);

            break;
        }

        // toss CRC (2 last bytes)
        // packetfunctions_tossFooter(&ieee154e_vars.ackReceived, LENGTH_CRC);

        // break if invalid CRC
        if (ieee154e_vars.ackReceived->l1_crc == FALSE) {
            // break from the do-while loop and execute the clean-up code below
            break;
        }

        // parse the IEEE802.15.4 header (RX ACK)
        ieee802154_retrieveHeader(ieee154e_vars.ackReceived, &ieee802514_header);

        // break if invalid IEEE802.15.4 header
        if (ieee802514_header.valid == FALSE) {
            // break from the do-while loop and execute the clean-up code below
            break;
        }

        // store header details in packet buffer
        ieee154e_vars.ackReceived->l2_frameType = ieee802514_header.frameType;
        ieee154e_vars.ackReceived->l2_dsn = ieee802514_header.dsn;
        memcpy(&(ieee154e_vars.ackReceived->l2_nextORpreviousHop), &(ieee802514_header.src), sizeof(open_addr_t));

        // verify that incoming security level is acceptable
        if (IEEE802154_security_acceptableLevel(ieee154e_vars.ackReceived, &ieee802514_header) == FALSE) {
            break;
        }

        // check the security level of the ACK frame and decrypt/authenticate
        if (ieee154e_vars.ackReceived->l2_securityLevel != IEEE154_ASH_SLF_TYPE_NOSEC) {
            if (IEEE802154_security_incomingFrame(ieee154e_vars.ackReceived) != E_SUCCESS) {
                break;
            }
        }

        // toss the IEEE802.15.4 header
        packetfunctions_tossHeader(&ieee154e_vars.ackReceived, ieee802514_header.headerLength);

        // break if invalid ACK
        if (isValidAck(&ieee802514_header, ieee154e_vars.dataToSend) == FALSE) {
            // break from the do-while loop and execute the clean-up code below
            break;
        }

        if (idmanager_getIsDAGroot() == FALSE &&
            icmpv6rpl_isPreferredParent(&(ieee154e_vars.ackReceived->l2_nextORpreviousHop))) {
            synchronizeAck(ieee802514_header.timeCorrection);//策略：向父级同步
        }

        // inform schedule of successful transmission
        schedule_indicateTx(&ieee154e_vars.asn, TRUE);

        // inform upper layer
        notif_sendDone(ieee154e_vars.dataToSend, E_SUCCESS);
        ieee154e_vars.dataToSend = NULL;

        // in any case, execute the clean-up code below (processing of ACK done)
    } while (0);

    // free the received ack so corresponding RAM memory can be recycled
    openqueue_freePacketBuffer(ieee154e_vars.ackReceived);

    // clear local variable
    ieee154e_vars.ackReceived = NULL;

    // official end of Tx slot
    endSlot();
}

//======= RX

port_INLINE void activity_ri2(void) {
    // change state
    changeState(S_RXDATAPREPARE);

#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm rt2
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_rt2,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );
    // configure the radio to listen to the default synchronizing channel
    radio_ble_setFrequency(ieee154e_vars.freq);
    radio_rxEnable();
#endif
    ieee154e_vars.radioOnInit = sctimer_readCounter();
    ieee154e_vars.radioOnThisSlot = TRUE;

    // change state
    changeState(S_RXDATAREADY);
}

port_INLINE void activity_rie1(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_MAXRXDATAPREPARE_OVERFLOWS,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);

    // abort
    endSlot();
}

port_INLINE void activity_ri3(void) {
    // change state
    changeState(S_RXDATALISTEN);
    //openserial_root_printf("rxNow: slot %d, channel %d",schedule_getSlottOffset(),schedule_getChannelOffset());
    // give the 'go' to receive
    radio_rxNow();
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm rt3
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_rt3,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );
#endif
}

port_INLINE void activity_rie2(void) {
    // abort
    endSlot();
}

port_INLINE void activity_ri4(PORT_TIMER_WIDTH capturedTime) {

    //openserial_root_printf("ri4:changeState(S_RXDATA)");
    // change state
    changeState(S_RXDATA);

#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // cancel rt3
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            ieee154e_vars.slotDuration,                       // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
#endif
    // record the captured time
    ieee154e_vars.lastCapturedTime = capturedTime;

    // record the captured time to sync
    ieee154e_vars.syncCapturedTime = capturedTime;
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_rt4,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );
#endif
}

port_INLINE void activity_rie3(void) {

    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_WDDATADURATION_OVERFLOWS,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);
    // abort
    endSlot();
}

port_INLINE void activity_ri5(PORT_TIMER_WIDTH capturedTime) {
    ieee802154_header_iht ieee802514_header;
    uint16_t lenIE = 0;
    open_addr_t addressToWrite;
    open_addr_t parentAddress;

    // change state
    changeState(S_TXACKOFFSET);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // cancel rt4
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            ieee154e_vars.slotDuration,                       // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
#endif
    // turn off the radio
    radio_rfOff();
    ieee154e_vars.radioOnTics += sctimer_readCounter() - ieee154e_vars.radioOnInit;
    // get a buffer to put the (received) data in
    ieee154e_vars.dataReceived = openqueue_getFreePacketBuffer(COMPONENT_IEEE802154E);
    if (ieee154e_vars.dataReceived == NULL) {
        // log the error
        LOG_ERROR(COMPONENT_IEEE802154E, ERR_NO_FREE_PACKET_BUFFER, (errorparameter_t) 0, (errorparameter_t) 0);
        // abort
        endSlot();
        return;
    }

    // declare ownership over that packet
    ieee154e_vars.dataReceived->creator = COMPONENT_IEEE802154E;
    ieee154e_vars.dataReceived->owner = COMPONENT_IEEE802154E;

    do { // this "loop" is only executed once
        // retrieve the received data frame from the radio's Rx buffer
        ieee154e_vars.dataReceived->payload = &(ieee154e_vars.dataReceived->packet[FIRST_FRAME_BYTE]);
        radio_ble_getReceivedFrame(
                ieee154e_vars.dataReceived->payload,
                (uint8_t * ) & ieee154e_vars.dataReceived->length,
                sizeof(ieee154e_vars.dataReceived->packet),
                &ieee154e_vars.dataReceived->l1_rssi,
                &ieee154e_vars.dataReceived->l1_lqi,
                &ieee154e_vars.dataReceived->l1_crc
        );
            #ifdef DEBUG_ROOT_RX
            openserial_root_printf("radio_ble_getReceivedFrame:len %d",ieee154e_vars.dataReceived->length);
            #endif
        // break if wrong length
        if (//ieee154e_vars.dataReceived->length < LENGTH_CRC ||
            ieee154e_vars.dataReceived->length > LENGTH_IEEE154_MAX) {
            // jump to the error code below this do-while loop
            LOG_ERROR(COMPONENT_IEEE802154E, ERR_INVALID_PACKET_FROM_RADIO,
                      (errorparameter_t) ieee154e_vars.dataReceived->length,
                      (errorparameter_t) 2);
            break;
        }

        // toss CRC (2 last bytes)
        //packetfunctions_tossFooter(&ieee154e_vars.dataReceived, LENGTH_CRC);

        // if CRC doesn't check, stop
        if (ieee154e_vars.dataReceived->l1_crc == FALSE) {
            // jump to the error code below this do-while loop
            break;
        }

        // parse the IEEE802.15.4 header (RX DATA)
        ieee802154_retrieveHeader(ieee154e_vars.dataReceived, &ieee802514_header);

        // break if invalid IEEE802.15.4 header
        if (ieee802514_header.valid == FALSE) {
            // break from the do-while loop and execute the clean-up code below
            break;
        }

        // store header details in packet buffer
        ieee154e_vars.dataReceived->l2_frameType = ieee802514_header.frameType;
        ieee154e_vars.dataReceived->l2_dsn = ieee802514_header.dsn;
        ieee154e_vars.dataReceived->l2_IEListPresent = ieee802514_header.ieListPresent;
        memcpy(&(ieee154e_vars.dataReceived->l2_nextORpreviousHop), &(ieee802514_header.src), sizeof(open_addr_t));

        // verify that incoming security level is acceptable
        if (IEEE802154_security_acceptableLevel(ieee154e_vars.dataReceived, &ieee802514_header) == FALSE) {
            break;
        }

        // if security is active and configured need to decrypt the frame
        if (ieee154e_vars.dataReceived->l2_securityLevel != IEEE154_ASH_SLF_TYPE_NOSEC) {
            if (IEEE802154_security_isConfigured()) {
                if (IEEE802154_security_incomingFrame(ieee154e_vars.dataReceived) != E_SUCCESS) {
                    break;
                }
            }
                // bypass authentication of beacons during join process
            else if (ieee154e_vars.dataReceived->l2_frameType == IEEE154_TYPE_BEACON) { // not joined yet
                packetfunctions_tossFooter(&ieee154e_vars.dataReceived,
                                           ieee154e_vars.dataReceived->l2_authenticationLength);
            } else {
                break;
            }
        }

        // toss the IEEE802.15.4 header
        packetfunctions_tossHeader(&ieee154e_vars.dataReceived, ieee802514_header.headerLength);

        if (
                ieee802514_header.frameType == IEEE154_TYPE_BEACON &&
                // if it is not a beacon and have ie, the ie will be processed in sixtop
                ieee802514_header.ieListPresent == TRUE &&
                packetfunctions_sameAddress(&ieee802514_header.panid, idmanager_getMyID(ADDR_PANID))
                ) {
            if (ieee154e_processIEs(ieee154e_vars.dataReceived, &lenIE) == FALSE) {
                // retrieve EB IE failed, break the do-while loop and execute the clean up code below
                break;
            }
        }

        // toss the IEs including Synch
        packetfunctions_tossHeader(&ieee154e_vars.dataReceived, lenIE);

        // record the captured time
        ieee154e_vars.lastCapturedTime = capturedTime;

        // if I just received an invalid frame, stop
        if (isValidRxFrame(&ieee802514_header) == FALSE) {
            // jump to the error code below this do-while loop
            break;
        }

        if (icmpv6rpl_getPreferredParentEui64(&parentAddress)) {
            if (packetfunctions_sameAddress(&ieee802514_header.src, &parentAddress)) {
                ieee154e_vars.receivedFrameFromParent = TRUE;
            }
        }

        // record the timeCorrection and print out at end of slot
        ieee154e_vars.dataReceived->l2_timeCorrection = (PORT_SIGNED_INT_WIDTH)(
                (PORT_SIGNED_INT_WIDTH) TsTxOffset - (PORT_SIGNED_INT_WIDTH) ieee154e_vars.syncCapturedTime);

        // check if ack requested
        if (ieee802514_header.ackRequested == 1 && ieee154e_vars.isAckEnabled == TRUE) {
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
            // arm rt5
            opentimers_scheduleAbsolute(
                    ieee154e_vars.timerId,                            // timerId
                    DURATION_rt5,                                     // duration
                    ieee154e_vars.startOfSlotReference,               // reference
                    TIME_TICS,                                        // timetype
                    isr_ieee154e_timer                                // callback
            );
#endif
        } else {

            // synchronize to the received packet if I'm not a DAGroot and this is my preferred parent or in case I'm
            // in the middle of the join process when parent is not yet selected or in case I don't have an autonomous
            // Tx cell cell to my parent yet
            if (
                    idmanager_getIsDAGroot() == FALSE &&
                    (
                            icmpv6rpl_isPreferredParent(&(ieee154e_vars.dataReceived->l2_nextORpreviousHop)) ||
                            IEEE802154_security_isConfigured() == FALSE //|| 
                            // //join process when parent is not yet selected
                            // icmpv6rpl_getPreferredParentEui64(&addressToWrite) == FALSE  ||
                            // (
                            //         icmpv6rpl_getPreferredParentEui64(&addressToWrite) &&
                            //         schedule_hasNegotiatedCellToNeighbor(&addressToWrite, CELLTYPE_TX) == FALSE
                            // )
                    )
                    ) {
                #if DEBUG_SYNC
                openserial_leader_printf("ri5:%d%d%d",idmanager_getIsDAGroot() == FALSE,icmpv6rpl_isPreferredParent(&(ieee154e_vars.dataReceived->l2_nextORpreviousHop)),IEEE802154_security_isConfigured() == FALSE);
                #endif
                synchronizePacket(ieee154e_vars.syncCapturedTime);
            }
            #if SCHEDULE_LEADER
            //storeMemberData(schedule_getMemberID(), ieee154e_vars.dataReceived->payload, ieee154e_vars.dataReceived->length);
                
                //record here，记录得到一个完整的坐标组。
                //标记在下次活动时隙时组长节点被允许向根节点发送坐标集合，
                //或者，仅仅标记当前坐标组完整的标志，后续逻辑可另作处理，
                //比如，当组长节点累积多个完整的坐标组之后，在下次多个连续活动时隙时才一次性发送。
                //这又涉及到支持在连续活动时隙中修改发送定时器时长的策略，目前默认是编译时确定。
            #endif
            // indicate reception to upper layer (no ACK asked)
            notif_receive(ieee154e_vars.dataReceived);
            
            // reset local variable
            ieee154e_vars.dataReceived = NULL;
            // abort
            endSlot();
        }

        // everything went well, return here not to execute the error code below
        return;

    } while (0);

    // free the (invalid) received data so RAM memory can be recycled
    openqueue_freePacketBuffer(ieee154e_vars.dataReceived);

    // clear local variable
    ieee154e_vars.dataReceived = NULL;

    // abort
    endSlot();
}

port_INLINE void activity_ri6(void) {

    // change state
    changeState(S_TXACKPREPARE);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm rt6
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_rt6,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );

    // get a buffer to put the ack to send in
    ieee154e_vars.ackToSend = openqueue_getFreePacketBuffer(COMPONENT_IEEE802154E);
    if (ieee154e_vars.ackToSend == NULL) {
        // log the error
        LOG_ERROR(COMPONENT_IEEE802154E, ERR_NO_FREE_PACKET_BUFFER, (errorparameter_t)0, (errorparameter_t)0);
        // indicate we received a packet anyway (we don't want to loose any)
        notif_receive(ieee154e_vars.dataReceived);
        // free local variable
        ieee154e_vars.dataReceived = NULL;
        // abort
        endSlot();
        return;
    }
    //openserial_mysf_printf("ack pkt got");

    // declare ownership over that packet
    ieee154e_vars.ackToSend->creator = COMPONENT_IEEE802154E;
    ieee154e_vars.ackToSend->owner = COMPONENT_IEEE802154E;

    // calculate the time timeCorrection (this is the time the sender is off w.r.t to this node. A negative number means
    // the sender is too late.
    ieee154e_vars.timeCorrection = (PORT_SIGNED_INT_WIDTH)(
            (PORT_SIGNED_INT_WIDTH) TsTxOffset - (PORT_SIGNED_INT_WIDTH) ieee154e_vars.syncCapturedTime);

    // prepend the IEEE802.15.4 header to the ACK
    ieee154e_vars.ackToSend->l2_frameType = IEEE154_TYPE_ACK;
    ieee154e_vars.ackToSend->l2_dsn = ieee154e_vars.dataReceived->l2_dsn;

    // To send ACK, we use the same security level (including NOSEC) and keys
    // that were present in the DATA packet.
    ieee154e_vars.ackToSend->l2_securityLevel = ieee154e_vars.dataReceived->l2_securityLevel;
    ieee154e_vars.ackToSend->l2_keyIdMode = ieee154e_vars.dataReceived->l2_keyIdMode;
    ieee154e_vars.ackToSend->l2_keyIndex = ieee154e_vars.dataReceived->l2_keyIndex;

    ieee802154_prependHeader(ieee154e_vars.ackToSend,
                             ieee154e_vars.ackToSend->l2_frameType,
                             FALSE,//no payloadIE in ack
                             ieee154e_vars.dataReceived->l2_dsn,
                             &(ieee154e_vars.dataReceived->l2_nextORpreviousHop)
    );

    // if security is enabled, encrypt directly in OpenQueue as there are no retransmissions for ACKs
    if (ieee154e_vars.ackToSend->l2_securityLevel != IEEE154_ASH_SLF_TYPE_NOSEC) {
        if (IEEE802154_security_outgoingFrameSecurity(ieee154e_vars.ackToSend) != E_SUCCESS) {
            openqueue_freePacketBuffer(ieee154e_vars.ackToSend);
            endSlot();
            return;
        }
    }
    // space for 2-byte CRC
    if (packetfunctions_reserveFooter(&ieee154e_vars.ackToSend, 2) == E_FAIL){
        endSlot();
        return;
    }
    // configure the radio to listen to the default synchronizing channel
    radio_ble_setFrequency(ieee154e_vars.freq);

    // load the packet in the radio's Tx buffer
    radio_ble_loadPacket(ieee154e_vars.ackToSend->payload, ieee154e_vars.ackToSend->length);
#endif
    // enable the radio in Tx mode. This does not send that packet.
    radio_txEnable();
    ieee154e_vars.radioOnInit = sctimer_readCounter();
    ieee154e_vars.radioOnThisSlot = TRUE;
    // change state
    changeState(S_TXACKREADY);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#endif
}

port_INLINE void activity_rie4(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_MAXTXACKPREPARE_OVERFLOWS,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);
    // abort
    endSlot();
}

port_INLINE void activity_ri7(void) {
    // change state
    changeState(S_TXACKDELAY);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm rt7
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_rt7,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );

    // give the 'go' to transmit
    radio_txNow();
    //openserial_mysf_printf("radio_txNow(), ack sending...");
#endif
}

port_INLINE void activity_rie5(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_WDRADIOTX_OVERFLOWS,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);
    // abort
    endSlot();
}

port_INLINE void activity_ri8(PORT_TIMER_WIDTH capturedTime) {
    // change state
    changeState(S_TXACK);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // cancel rt7
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            ieee154e_vars.slotDuration,                       // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
#endif
    // record the captured time
    ieee154e_vars.lastCapturedTime = capturedTime;
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // arm rt8
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            DURATION_rt8,                                     // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_timer                                // callback
    );
#endif
}

port_INLINE void activity_rie6(void) {
    // log the error
    LOG_ERROR(COMPONENT_IEEE802154E, ERR_WDACKDURATION_OVERFLOWS,
              (errorparameter_t) ieee154e_vars.state,
              (errorparameter_t) ieee154e_vars.slotOffset);
    // abort
    endSlot();
}

port_INLINE void activity_ri9(PORT_TIMER_WIDTH capturedTime) {
    // change state
    changeState(S_RXPROC);
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    // cancel rt8
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            ieee154e_vars.slotDuration,                       // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
#endif
    // record the captured time
    ieee154e_vars.lastCapturedTime = capturedTime;

    // free the ack we just sent so corresponding RAM memory can be recycled
    openqueue_freePacketBuffer(ieee154e_vars.ackToSend);

    // clear local variable
    ieee154e_vars.ackToSend = NULL;

    if ((idmanager_getIsDAGroot() == FALSE &&
         icmpv6rpl_isPreferredParent(&(ieee154e_vars.dataReceived->l2_nextORpreviousHop))) ||
        IEEE802154_security_isConfigured() == FALSE) {
        #if DEBUG_SYNC
        openserial_leader_printf("ri9:%d,%d,%d",(idmanager_getIsDAGroot() == FALSE),icmpv6rpl_isPreferredParent(&(ieee154e_vars.dataReceived->l2_nextORpreviousHop)),IEEE802154_security_isConfigured() == FALSE);
        #endif
        (ieee154e_vars.syncCapturedTime);
    }

    // inform upper layer of reception (after ACK sent)
    notif_receive(ieee154e_vars.dataReceived);

    // clear local variable
    ieee154e_vars.dataReceived = NULL;

    // official end of Rx slot
    endSlot();
}

//======= frame validity check

/**
\brief Decides whether the packet I just received is valid received frame.

A valid Rx frame satisfies the following constraints:
- its IEEE802.15.4 header is well formatted
- it's a DATA of BEACON frame (i.e. not ACK and not COMMAND)
- it's sent on the same PANid as mine
- it's for me (unicast or broadcast)

\param[in] ieee802514_header IEEE802.15.4 header of the packet I just received

\returns TRUE if packet is valid received frame, FALSE otherwise
*/
port_INLINE bool isValidRxFrame(ieee802154_header_iht* ieee802514_header) {
    //openserial_mysf_printf("isValidRxFrame()");
    return
    (ieee802514_header->valid == TRUE &&
    (ieee802514_header->frameType==IEEE154_TYPE_DATA  || ieee802514_header->frameType==IEEE154_TYPE_BEACON) &&
    packetfunctions_sameAddress(&ieee802514_header->panid, idmanager_getMyID(ADDR_PANID))  &&
    (idmanager_isMyAddress(&ieee802514_header->dest) || packetfunctions_isBroadcastMulticast(&ieee802514_header->dest)));
}

/**
\brief Decides whether the packet I just received is a valid ACK.

A packet is a valid ACK if it satisfies the following conditions:
- the IEEE802.15.4 header is valid
- the frame type is 'ACK'
- the sequence number in the ACK matches the sequence number of the packet sent
- the ACK contains my PANid
- the packet is unicast to me
- the packet comes from the neighbor I sent the data to

\param[in] ieee802514_header IEEE802.15.4 header of the packet I just received
\param[in] packetSent points to the packet I just sent

\returns TRUE if packet is a valid ACK, FALSE otherwise.
*/
port_INLINE bool isValidAck(ieee802154_header_iht* ieee802514_header, OpenQueueEntry_t* packetSent) {
    return ieee802514_header->valid == TRUE && \
        ieee802514_header->frameType == IEEE154_TYPE_ACK && \
        packetfunctions_sameAddress(&ieee802514_header->panid, idmanager_getMyID(ADDR_PANID)) && \
        idmanager_isMyAddress(&ieee802514_header->dest) && \
        packetfunctions_sameAddress(&ieee802514_header->src, &packetSent->l2_nextORpreviousHop);
}

//======= ASN handling

port_INLINE void incrementAsnOffset(void) {
    frameLength_t frameLength;

    // increment the asn
    ieee154e_vars.asn.bytes0and1++;
    if (ieee154e_vars.asn.bytes0and1 == 0) {
        ieee154e_vars.asn.bytes2and3++;
        if (ieee154e_vars.asn.bytes2and3 == 0) {
            ieee154e_vars.asn.byte4++;
        }
    }

    // increment the offsets
    frameLength = schedule_getFrameLength();
    if (frameLength == 0) {
        ieee154e_vars.slotOffset++;
    } else {
        ieee154e_vars.slotOffset = (ieee154e_vars.slotOffset + 1) % frameLength;
    }
    ieee154e_vars.asnOffset = (ieee154e_vars.asnOffset + 1) % NUM_CHANNELS;
}

port_INLINE void ieee154e_resetAsn(void) {
    // reset slotoffset
    ieee154e_vars.slotOffset = 0;
    ieee154e_vars.asnOffset = 0;
    // reset asn
    ieee154e_vars.asn.byte4 = 0;
    ieee154e_vars.asn.bytes2and3 = 0;
    ieee154e_vars.asn.bytes0and1 = 0;
}

//from upper layer that want to send the ASN to compute timing or latency
port_INLINE void ieee154e_getAsn(uint8_t *array) {
    array[0] = (ieee154e_vars.asn.bytes0and1 & 0xff);
    array[1] = (ieee154e_vars.asn.bytes0and1 / 256 & 0xff);
    array[2] = (ieee154e_vars.asn.bytes2and3 & 0xff);
    array[3] = (ieee154e_vars.asn.bytes2and3 / 256 & 0xff);
    array[4] = ieee154e_vars.asn.byte4;
}

port_INLINE uint16_t ieee154e_getTimeCorrection(void) {
    int16_t returnVal;

    returnVal = (uint16_t)(ieee154e_vars.timeCorrection);
    return returnVal;
}

void ieee154e_getTicsInfo(uint32_t *numTicsOn, uint32_t *numTicsTotal) {
    *numTicsOn = (uint32_t)(ieee154e_stats.numTicsOn);
    *numTicsTotal = (uint32_t)(ieee154e_stats.numTicsTotal);
}

port_INLINE void joinPriorityStoreFromEB(uint8_t jp) {
    ieee154e_vars.dataReceived->l2_joinPriority = jp;
    ieee154e_vars.dataReceived->l2_joinPriorityPresent = TRUE;
}

/*
 * This function parses IEs from an EB to get to the ASN before security processing is invoked. It should be called
 * *only* when a node has no/lost sync. This way, we can authenticate EBs and reject unwanted ones.
 */
bool isValidJoin(OpenQueueEntry_t *eb, ieee802154_header_iht *parsedHeader) {
    uint16_t lenIE;

    // toss the header in order to get to IEs
    packetfunctions_tossHeader(&eb, parsedHeader->headerLength);

    // process IEs
    // at this stage, this can work only if EB is authenticated but not encrypted
    lenIE = 0;
    if (
            (
                    parsedHeader->valid == TRUE &&
                    parsedHeader->ieListPresent == TRUE &&
                    parsedHeader->frameType == IEEE154_TYPE_BEACON &&
                    packetfunctions_sameAddress(&parsedHeader->panid, idmanager_getMyID(ADDR_PANID)) &&
                    ieee154e_processIEs(eb, &lenIE)
            ) == FALSE
            ) {
        return FALSE;
    }

    // put everything back in place in order to invoke security-incoming on the correct frame length and correct
    // pointers (first byte of the frame)
    if (packetfunctions_reserveHeader(&eb, parsedHeader->headerLength) == E_FAIL){
        // this should not happen!
        return FALSE;
    }

    // verify EB's authentication tag if keys are configured
    if (IEEE802154_security_isConfigured()) {
        if (IEEE802154_security_incomingFrame(eb) == E_SUCCESS) {
            return TRUE;
        }
    } else {
        // bypass authentication check for beacons if security is not configured
        packetfunctions_tossFooter(&eb, eb->l2_authenticationLength);
        return TRUE;
    }

    return FALSE;
}

bool isValidEbFormat(OpenQueueEntry_t *pkt, uint16_t *lenIE) {

    bool chTemplate_checkPass;
    bool tsTemplate_checkpass;
    bool sync_ie_checkPass;
    bool slotframelink_ie_checkPass;

    uint8_t ptr;
    uint16_t temp16b;
    bool mlme_ie_found;
    uint8_t mlme_ie_content_offset;
    uint8_t ielen;

    uint8_t subtype;
    uint8_t sublen;
    uint8_t subid;

    uint8_t i;
    uint8_t oldFrameLength;
    uint8_t numlinks;
    open_addr_t temp_neighbor;
    uint16_t slotoffset;
    uint16_t channeloffset;

    chTemplate_checkPass = FALSE;
    tsTemplate_checkpass = FALSE;
    sync_ie_checkPass = FALSE;
    slotframelink_ie_checkPass = FALSE;

    ptr = 0;
    mlme_ie_found = FALSE;

    while (ptr < pkt->length) {

        temp16b = *((uint8_t * )(pkt->payload) + ptr);
        temp16b |= (*((uint8_t * )(pkt->payload) + ptr + 1)) << 8;
        ptr += 2;

        ielen = temp16b & IEEE802154E_DESC_LEN_PAYLOAD_IE_MASK;

        if (
                (temp16b & IEEE802154E_DESC_GROUPID_PAYLOAD_IE_MASK) >> IEEE802154E_DESC_GROUPID_PAYLOAD_IE_SHIFT !=
                IEEE802154E_MLME_IE_GROUPID ||
                (temp16b & IEEE802154E_DESC_TYPE_LONG) == 0
                ) {
            // this is not MLME IE
            ptr += ielen;
        } else {
            // found the MLME payload IE
            mlme_ie_found = TRUE;
            mlme_ie_content_offset = ptr;
            break;
        }
    }

    if (mlme_ie_found == FALSE) {
        // didn't find the MLME payload IE
        return FALSE;
    }

    while (
            ptr < mlme_ie_content_offset + ielen &&
            (
                    chTemplate_checkPass == FALSE || tsTemplate_checkpass == FALSE ||
                    sync_ie_checkPass == FALSE || slotframelink_ie_checkPass == FALSE
            )
            ) {
        // subID
        temp16b = *((uint8_t * )(pkt->payload) + ptr);
        temp16b |= (*((uint8_t * )(pkt->payload) + ptr + 1)) << 8;
        ptr += 2;

        subtype = (temp16b & IEEE802154E_DESC_TYPE_IE_MASK) >> IEEE802154E_DESC_TYPE_IE_SHIFT;
        if (subtype == 1) {
            // this is long type subID
            subid = (temp16b & IEEE802154E_DESC_SUBID_LONG_MLME_IE_MASK) >> IEEE802154E_DESC_SUBID_LONG_MLME_IE_SHIFT;
            sublen = (temp16b & IEEE802154E_DESC_LEN_LONG_MLME_IE_MASK);
            switch (subid) {
                case IEEE802154E_MLME_CHANNELHOPPING_IE_SUBID:
                    channelhoppingTemplateIDStoreFromEB(*((uint8_t * )(pkt->payload + ptr)));
                    chTemplate_checkPass = TRUE;
                    break;
                default:
                    // unsupported IE type, skip the ie
                    break;
            }
        } else {
            // this is short type subID
            subid = (temp16b & IEEE802154E_DESC_SUBID_SHORT_MLME_IE_MASK) >> IEEE802154E_DESC_SUBID_SHORT_MLME_IE_SHIFT;
            sublen = (temp16b & IEEE802154E_DESC_LEN_SHORT_MLME_IE_MASK);
            switch (subid) {
                case IEEE802154E_MLME_SYNC_IE_SUBID:
                    asnStoreFromEB((uint8_t * )(pkt->payload + ptr));
                    joinPriorityStoreFromEB(*((uint8_t * )(pkt->payload) + ptr + 5));
                    sync_ie_checkPass = TRUE;
                    break;
                case IEEE802154E_MLME_TIMESLOT_IE_SUBID:
                    timeslotTemplateIDStoreFromEB(*((uint8_t * )(pkt->payload) + ptr));
                    tsTemplate_checkpass = TRUE;
                    break;
                case IEEE802154E_MLME_SLOTFRAME_LINK_IE_SUBID:
                    schedule_setFrameNumber(*((uint8_t * )(pkt->payload) + ptr));           // number of slotframes
                    schedule_setFrameHandle(*((uint8_t * )(pkt->payload) + ptr + 1));       // slotframe id
                    oldFrameLength = schedule_getFrameLength();
                    if (oldFrameLength == 0) {
                        temp16b = *((uint8_t * )(pkt->payload + ptr + 2));                  // slotframes length
                        temp16b |= *((uint8_t * )(pkt->payload + ptr + 3)) << 8;
                        schedule_setFrameLength(temp16b);
                        numlinks = *((uint8_t * )(pkt->payload + ptr + 4));                 // number of links

                        // shared TXRX anycast slot(s)
                        memset(&temp_neighbor, 0, sizeof(temp_neighbor));
                        temp_neighbor.type = ADDR_ANYCAST;

                        for (i = 0; i < numlinks; i++) {
                            slotoffset = *((uint8_t * )(pkt->payload + ptr + 5 + 5 * i));               // slotframes length
                            slotoffset |= *((uint8_t * )(pkt->payload + ptr + 5 + 5 * i + 1)) << 8;

                            channeloffset = *((uint8_t * )(pkt->payload + ptr + 5 + 5 * i + 2));        // slotframes length
                            channeloffset |= *((uint8_t * )(pkt->payload + ptr + 5 + 5 * i + 3)) << 8;
                        //不再在此处添加时隙，手动指定EB时隙。
                            switch (center_vars.role)
                            {
                            case CENTER_ROLE_LEADER:
                                //用于syncslot
                                schedule_addActiveSlot(
                                        slotoffset,    // slot offset
                                        CELLTYPE_TEMP, // type of slot
                                        FALSE,         // shared?
                                        FALSE,         // auto cell
                                        channeloffset, // channel offset
                                        &temp_neighbor // neighbor
                                );
                                //openserial_leader_printf("myId:%d",center_vars.myId);
                                //用于EB
                                center_vars.ebSlot = slotoffset + center_vars.myId + 1;
                                center_vars.ebChannel = channeloffset + center_vars.myId + 1;
                                openserial_leader_printf("ebslot:%d,ebchannel:%d",center_vars.ebSlot,center_vars.ebChannel);
                                schedule_addActiveSlot(
                                        center_vars.ebSlot,    // slot offset
                                        CELLTYPE_TX, // type of slot
                                        FALSE,          // shared?
                                        FALSE,         // auto cell
                                        center_vars.ebChannel, // channel offset
                                        &temp_neighbor // neighbor
                                );
                                break;
                                
                            case CENTER_ROLE_MEMBER:
                                //用于syncslot
                                //openserial_member_printf("eb, slot:%d,chan:%d",slotoffset+center_vars.groupId,channeloffset+center_vars.groupId);

                                schedule_addActiveSlot(
                                        slotoffset + center_vars.groupId + 1,    // slot offset
                                        CELLTYPE_TEMP, // type of slot
                                        FALSE,         // shared?
                                        FALSE,         // auto cell
                                        channeloffset + center_vars.groupId + 1, // channel offset
                                        &temp_neighbor // neighbor
                                );
                                schedule_addActiveSlot(
                                        MEMBER_LEADER_UPLINK_SLOT,    // slot offset
                                        CELLTYPE_TX,   // type of slot
                                        FALSE,          // shared?
                                        FALSE,         // auto cell
                                        MEMBER_LEADER_UPLINK_CHANNEL, // channel offset
                                        &temp_neighbor // neighbor
                                );

                                break;
                            default:
                                break;
                            }

                        }
                    }
                    slotframelink_ie_checkPass = TRUE;
                    break;
                default:
                    // unsupported IE type, skip the ie
                    break;
            }
        }
        ptr += sublen;
    }

    if (chTemplate_checkPass && tsTemplate_checkpass && sync_ie_checkPass && slotframelink_ie_checkPass) {
        *lenIE = pkt->length;
        return TRUE;
    } else {
        return FALSE;
    }
}

port_INLINE void asnStoreFromEB(uint8_t *asn) {

    // store the ASN
    ieee154e_vars.asn.bytes0and1 = asn[0] + 256 * asn[1];
    ieee154e_vars.asn.bytes2and3 = asn[2] + 256 * asn[3];
    ieee154e_vars.asn.byte4 = asn[4];
}

port_INLINE void ieee154e_syncSlotOffset(void) {
    frameLength_t frameLength;
    uint32_t slotOffset;
    uint8_t i;

    frameLength = schedule_getFrameLength();

    // determine the current slotOffset
    slotOffset = ieee154e_vars.asn.byte4;
    slotOffset = slotOffset % frameLength;
    slotOffset = slotOffset << 16;
    slotOffset = slotOffset + ieee154e_vars.asn.bytes2and3;
    slotOffset = slotOffset % frameLength;
    slotOffset = slotOffset << 16;
    slotOffset = slotOffset + ieee154e_vars.asn.bytes0and1;
    slotOffset = slotOffset % frameLength;

    ieee154e_vars.slotOffset = (slotOffset_t) slotOffset;

    schedule_syncSlotOffset(ieee154e_vars.slotOffset);
    ieee154e_vars.nextActiveSlotOffset = schedule_getNextActiveSlotOffset();
    /*
    infer the asnOffset based on the fact that
    ieee154e_vars.freq = 11 + (asnOffset + channelOffset)%16
    */
    for (i = 0; i < NUM_CHANNELS; i++) {
        //channel = 11 + chTemplate[(asnOffset + channelOffset) % NUM_CHANNELS]
        if ((ieee154e_vars.freq - 11) == ieee154e_vars.chTemplate[i]) {
            break;
        }
    }
    ieee154e_vars.asnOffset = i - schedule_getChannelOffset();
}

uint16_t ieee154e_getSlotDuration(void) {
    return ieee154e_vars.slotDuration;
}

// timeslot template handling
port_INLINE void timeslotTemplateIDStoreFromEB(uint8_t id) {
    ieee154e_vars.tsTemplateId = id;
}

// channelhopping template handling
port_INLINE void channelhoppingTemplateIDStoreFromEB(uint8_t id) {
    ieee154e_vars.chTemplateId = id;
}
//======= synchronization

// void synchronizePacket(PORT_TIMER_WIDTH timeReceived) {
//     PORT_SIGNED_INT_WIDTH timeCorrection;
//     PORT_TIMER_WIDTH newPeriod;
//     PORT_TIMER_WIDTH currentPeriod;
//     PORT_TIMER_WIDTH currentValue;

//     // record the current timer value and period
//     currentValue = opentimers_getValue() - ieee154e_vars.startOfSlotReference;
//     currentPeriod = ieee154e_vars.slotDuration;

//     // calculate new period
//     timeCorrection = (PORT_SIGNED_INT_WIDTH)((PORT_SIGNED_INT_WIDTH) timeReceived - (PORT_SIGNED_INT_WIDTH) TsTxOffset);

//     // The interrupt beginning a new slot can either occur after the packet has been or while it is being received,
//     // possibly because the mote is not yet synchronized. In the former case we simply take the usual slotLength and
//     // correct it. In the latter case the timer did already roll over and currentValue < timeReceived. SlotLength did
//     // then already pass which is why we need the new slot to end after the remaining time which is timeCorrection
//     // and in this constellation is guaranteed to be positive.

//     /* to understand why currentValue < timeReceived can happen, refer to the following code:
//         //I'm in the middle of receiving a packet
//         if (ieee154e_vars.state == S_SYNCRX) {
//             return;
//         }
//         this judgement stops the new slot period, and return back to last slot, where it's just before changeIsSync(TRUE);
//         however, though the process goes back to last slot, the current time is based on the new slot. 
//     */

//     if (ieee154e_vars.numOfnewSlot != ieee154e_dbg.num_newSlot) {
//         newPeriod = (PORT_TIMER_WIDTH) timeCorrection;
//     } else {
//         newPeriod = (PORT_TIMER_WIDTH)((PORT_SIGNED_INT_WIDTH) currentPeriod + timeCorrection);
//     }

//     // detect whether I'm too close to the edge of the slot, in that case, skip a slot and increase the temporary slot
//     // length to be 2 slots long
//     if ((PORT_SIGNED_INT_WIDTH) newPeriod - (PORT_SIGNED_INT_WIDTH) currentValue <
//         (PORT_SIGNED_INT_WIDTH) RESYNCHRONIZATIONGUARD) {
//         newPeriod += TsSlotDuration;
//         incrementAsnOffset();
//     }

//     // resynchronize by applying the new period
//     opentimers_scheduleAbsolute(
//             ieee154e_vars.timerId,                            // timerId
//             newPeriod,                                        // duration
//             ieee154e_vars.startOfSlotReference,               // reference
//             TIME_TICS,                                        // timetype
//             isr_ieee154e_newSlot                              // callback
//     );
//     ieee154e_vars.slotDuration = newPeriod;
//     // indicate time correction to adaptive sync module
// #if OPENWSN_ADAPTIVE_SYNC_C
//     adaptive_sync_indicateTimeCorrection(timeCorrection,ieee154e_vars.dataReceived->l2_nextORpreviousHop);
// #endif
//     // reset the de-synchronization timeout
//     openserial_leader_printf("syncpkt: reset ieee154e_vars.deSyncTimeout");
//     ieee154e_vars.deSyncTimeout = DESYNCTIMEOUT;

//     // log a large timeCorrection
//     if (
//             ieee154e_vars.isSync == TRUE &&
//             (
//                     timeCorrection < -LIMITLARGETIMECORRECTION || timeCorrection > LIMITLARGETIMECORRECTION
//             )
//             ) {
//         LOG_WARNING(COMPONENT_IEEE802154E, ERR_LARGE_TIMECORRECTION,
//                 (errorparameter_t) timeCorrection,
//                 (errorparameter_t) 0);
//     }

//     // update the stats
//     ieee154e_stats.numSyncPkt++;
//     updateStats(timeCorrection);

// #ifdef OPENSIM
//     debugpins_syncPacket_set();
//     debugpins_syncPacket_clr();
// #endif
// }
void synchronizePacket(PORT_TIMER_WIDTH timeReceived) {
    PORT_SIGNED_INT_WIDTH timeCorrection;
    PORT_TIMER_WIDTH newPeriod;
    PORT_TIMER_WIDTH currentPeriod;
    PORT_TIMER_WIDTH currentValue;

    // record the current timer value and period
    currentValue = opentimers_getValue() - ieee154e_vars.startOfSlotReference;
    currentPeriod = ieee154e_vars.slotDuration;

    // calculate new period
    timeCorrection = (PORT_SIGNED_INT_WIDTH)((PORT_SIGNED_INT_WIDTH) timeReceived - (PORT_SIGNED_INT_WIDTH) TsTxOffset);

    // The interrupt beginning a new slot can either occur after the packet has been or while it is being received,
    // possibly because the mote is not yet synchronized. In the former case we simply take the usual slotLength and
    // correct it. In the latter case the timer did already roll over and currentValue < timeReceived. SlotLength did
    // then already pass which is why we need the new slot to end after the remaining time which is timeCorrection
    // and in this constellation is guaranteed to be positive.

    if (currentValue < timeReceived) {
        newPeriod = (PORT_TIMER_WIDTH) timeCorrection;
    } else {
        newPeriod = (PORT_TIMER_WIDTH)((PORT_SIGNED_INT_WIDTH) currentPeriod + timeCorrection);
    }

    // detect whether I'm too close to the edge of the slot, in that case, skip a slot and increase the temporary slot
    // length to be 2 slots long
    if ((PORT_SIGNED_INT_WIDTH) newPeriod - (PORT_SIGNED_INT_WIDTH) currentValue <
        (PORT_SIGNED_INT_WIDTH) RESYNCHRONIZATIONGUARD) {
        newPeriod += TsSlotDuration;
        incrementAsnOffset();
    }

    // resynchronize by applying the new period
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            newPeriod,                                        // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
    ieee154e_vars.slotDuration = newPeriod;
    // indicate time correction to adaptive sync module
#if OPENWSN_ADAPTIVE_SYNC_C
    adaptive_sync_indicateTimeCorrection(timeCorrection,ieee154e_vars.dataReceived->l2_nextORpreviousHop);
#endif
    // reset the de-synchronization timeout
    ieee154e_vars.deSyncTimeout = DESYNCTIMEOUT;

    // log a large timeCorrection
    if (
            ieee154e_vars.isSync == TRUE &&
            (
                    timeCorrection < -LIMITLARGETIMECORRECTION || timeCorrection > LIMITLARGETIMECORRECTION
            )
            ) {
        LOG_WARNING(COMPONENT_IEEE802154E, ERR_LARGE_TIMECORRECTION,
                (errorparameter_t) timeCorrection,
                (errorparameter_t) ieee154e_vars.dataReceived->l2_nextORpreviousHop.addr_64b[7]);
    }

    // update the stats
    ieee154e_stats.numSyncPkt++;
    updateStats(timeCorrection);

#ifdef OPENSIM
    debugpins_syncPacket_set();
    debugpins_syncPacket_clr();
#endif
}
void synchronizeAck(PORT_SIGNED_INT_WIDTH timeCorrection) {
    PORT_TIMER_WIDTH newPeriod;
    PORT_TIMER_WIDTH currentPeriod;

    //openserial_leader_printf("synchronizeAck");
    // calculate new period
    currentPeriod = ieee154e_vars.slotDuration;
    newPeriod = (PORT_TIMER_WIDTH)((PORT_SIGNED_INT_WIDTH) currentPeriod + timeCorrection);

    // resynchronize by applying the new period
    opentimers_scheduleAbsolute(
            ieee154e_vars.timerId,                            // timerId
            newPeriod,                                        // duration
            ieee154e_vars.startOfSlotReference,               // reference
            TIME_TICS,                                        // timetype
            isr_ieee154e_newSlot                              // callback
    );
    ieee154e_vars.slotDuration = newPeriod;

    // reset the de-synchronization timeout
    #if DEBUG_SYNC
    openserial_leader_printf("syncpkt_ack: reset ieee154e_vars.deSyncTimeout");
    openserial_member_printf("syncpkt_ack: reset ieee154e_vars.deSyncTimeout");
    #endif
    
    ieee154e_vars.deSyncTimeout = DESYNCTIMEOUT;

#if OPENWSN_ADAPTIVE_SYNC_C
    // indicate time correction to adaptive sync module
    adaptive_sync_indicateTimeCorrection((-timeCorrection),ieee154e_vars.ackReceived->l2_nextORpreviousHop);
#endif
    // log a large timeCorrection
    if (ieee154e_vars.isSync == TRUE && (
            timeCorrection < -LIMITLARGETIMECORRECTION || timeCorrection > LIMITLARGETIMECORRECTION
            )) {
        LOG_WARNING(COMPONENT_IEEE802154E, ERR_LARGE_TIMECORRECTION,
                (errorparameter_t) timeCorrection,
                (errorparameter_t) 1);
    }

    // update the stats
    ieee154e_stats.numSyncAck++;
    updateStats(timeCorrection);

#ifdef OPENSIM
    debugpins_syncAck_set();
    debugpins_syncAck_clr();
#endif
}

void changeIsSync(bool newIsSync) {
    ieee154e_vars.isSync = newIsSync;

    if (ieee154e_vars.isSync == TRUE) {
        leds_sync_on();
        resetStats();
    } else {
        leds_sync_off();
        schedule_resetBackoff();
    }
}

//======= notifying upper layer

void notif_sendDone(OpenQueueEntry_t *packetSent, owerror_t error) {
    if(packetSent->creator == COMPONENT_CENTER_SCHEDULE)
        openserial_mysf_printf("pkt to id:%d, created by:%d, slot:%d, channel:%d, notif_sendDone, %s",
            packetSent->l2_nextORpreviousHop.addr_64b[7],packetSent->creator,schedule_getSlottOffset(),schedule_getChannelOffset(),error?"FAIL":"SUCCESS");
    //openserial_root_printf("notif_sendDone & scheduler_push_task");
    // record the outcome of the transmission attempt
    packetSent->l2_sendDoneError = error;
    // record the current ASN
    memcpy(&packetSent->l2_asn, &ieee154e_vars.asn, sizeof(asn_t));
    // associate this packet with the virtual component COMPONENT_IEEE802154E_TO_RES so RES can knows it's for it
    packetSent->owner = COMPONENT_IEEE802154E_TO_SIXTOP;
    // post RES's sendDone task
    scheduler_push_task(task_sixtopNotifSendDone, TASKPRIO_SIXTOP_NOTIF_TXDONE);
    // wake up the scheduler
    SCHEDULER_WAKEUP();
}

void notif_receive(OpenQueueEntry_t *packetReceived) {
    openserial_mysf_printf("notif_receive,type:%d,src:%d,len:%d,slot:%d,channel:%d",
    packetReceived->l2_frameType,packetReceived->l2_nextORpreviousHop.addr_64b[7],packetReceived->length,
    schedule_getSlottOffset(),schedule_getChannelOffset());
    // record the current ASN
    memcpy(&packetReceived->l2_asn, &ieee154e_vars.asn, sizeof(asn_t));
    // indicate reception to the schedule, to keep statistics
    schedule_indicateRx(&packetReceived->l2_asn);
    // associate this packet with the virtual component
    // COMPONENT_IEEE802154E_TO_SIXTOP so sixtop can knows it's for it
    packetReceived->owner = COMPONENT_IEEE802154E_TO_SIXTOP;
    // post RES's Receive task
    scheduler_push_task(task_sixtopNotifReceive, TASKPRIO_SIXTOP_NOTIF_RX);
    // wake up the scheduler
    SCHEDULER_WAKEUP();
}

//======= stats

port_INLINE void resetStats(void) {
    ieee154e_stats.numSyncPkt = 0;
    ieee154e_stats.numSyncAck = 0;
    ieee154e_stats.minCorrection = 127;
    ieee154e_stats.maxCorrection = -127;
    ieee154e_stats.numTicsOn = 0;
    ieee154e_stats.numTicsTotal = 0;
    // do not reset the number of de-synchronizations
}

void updateStats(PORT_SIGNED_INT_WIDTH timeCorrection) {
    // update minCorrection
    if (timeCorrection < ieee154e_stats.minCorrection) {
        ieee154e_stats.minCorrection = timeCorrection;
    }
    // update maxConnection
    if (timeCorrection > ieee154e_stats.maxCorrection) {
        ieee154e_stats.maxCorrection = timeCorrection;
    }
}

//======= misc

/**
\brief Calculates the frequency channel to transmit on, based on the absolute slot number and the channel offset of
 the requested slot.

During normal operation, the frequency used is a function of the channelOffset indicating in the schedule, and of the
ASN of the slot. This ensures channel hopping, consecutive packets sent in the same slot in the schedule are done on a
difference frequency channel.

During development, you can force single channel operation by having this function return a constant channel number
(between 11 and 26). This allows you to use a single-channel sniffer; but you can not schedule two links on two
different channel offsets in the same slot.

\param[in] channelOffset channel offset for the current slot

\returns The calculated frequency channel, an integer between 11 and 26.
*/
port_INLINE uint8_t calculateFrequency(uint8_t channelOffset) {
    if (ieee154e_vars.singleChannel >= 11 && ieee154e_vars.singleChannel <= 26 ) {
        return ieee154e_vars.singleChannel; // single channel
    } else {
        // channel hopping enabled, use the channel depending on hopping template
        //return 11 + ieee154e_vars.chTemplate[(ieee154e_vars.asnOffset + channelOffset) % NUM_CHANNELS];
        return 11 + ieee154e_vars.chTemplate[channelOffset % NUM_CHANNELS];
    }
}

/**
\brief Changes the state of the IEEE802.15.4e FSM.

Besides simply updating the state global variable, this function toggles the FSM debug pin.

\param[in] newstate The state the IEEE802.15.4e FSM is now in.
*/
void changeState(ieee154e_state_t newstate) {
    // update the state
    ieee154e_vars.state = newstate;
    // wiggle the FSM debug pin
    switch (ieee154e_vars.state) {
        case S_SYNCLISTEN:
        case S_TXDATAOFFSET:
            debugpins_fsm_set();
            break;
        case S_SLEEP:
        case S_RXDATAOFFSET:
            debugpins_fsm_clr();
            break;
        case S_SYNCRX:
        case S_SYNCPROC:
        case S_TXDATAPREPARE:
        case S_TXDATAREADY:
        case S_TXDATADELAY:
        case S_TXDATA:
        case S_RXACKOFFSET:
        case S_RXACKPREPARE:
        case S_RXACKREADY:
        case S_RXACKLISTEN:
        case S_RXACK:
        case S_TXPROC:
        case S_RXDATAPREPARE:
        case S_RXDATAREADY:
        case S_RXDATALISTEN:
        case S_RXDATA:
        case S_TXACKOFFSET:
        case S_TXACKPREPARE:
        case S_TXACKREADY:
        case S_TXACKDELAY:
        case S_TXACK:
        case S_RXPROC:
            debugpins_fsm_toggle();
            break;
    }
}

/**
\brief Housekeeping tasks to do at the end of each slot.

This functions is called once in each slot, when there is nothing more to do. This might be when an error occurred, or
when everything went well. This function resets the state of the FSM so it is ready for the next slot.

Note that by the time this function is called, any received packet should already have been sent to the upper layer.
Similarly, in a Tx slot, the sendDone function should already have been done. If this is not the case, this function
will do that for you, but assume that something went wrong.
*/


// === 子函数实现 ===

/**
 * 处理无线电关闭、定时器清理和占空比计算
 */
static void handleRadioAndTiming(void) {
    // 关闭无线电
    radio_rfOff();

    // 计算本时隙的占空比
    if (ieee154e_vars.radioOnThisSlot == TRUE) {
        ieee154e_vars.radioOnTics += (sctimer_readCounter() - ieee154e_vars.radioOnInit);
    }

    // 清理定时器
#ifdef SLOT_FSM_IMPLEMENTATION_MULTIPLE_TIMER_INTERRUPT
#else
    opentimers_scheduleAbsolute(
        ieee154e_vars.timerId,
        ieee154e_vars.slotDuration,
        ieee154e_vars.startOfSlotReference,
        TIME_TICS,
        isr_ieee154e_newSlot
    );
#endif

    // 重置捕获时间
    ieee154e_vars.lastCapturedTime = 0;
    ieee154e_vars.syncCapturedTime = 0;

    // 更新占空比统计
    ieee154e_stats.numTicsOn += ieee154e_vars.radioOnTics;
    ieee154e_stats.numTicsTotal += ieee154e_vars.slotDuration;

    // 防止统计值溢出
    if (ieee154e_stats.numTicsTotal > DUTY_CYCLE_WINDOW_LIMIT) {
        ieee154e_stats.numTicsTotal >>= 1;
        ieee154e_stats.numTicsOn >>= 1;
    }

    // 清理本时隙占空比变量
    ieee154e_vars.radioOnTics = 0;
    ieee154e_vars.radioOnThisSlot = FALSE;
}

/**
 * 处理所有待处理的数据包和清理缓冲区
 */
static void handlePacketsAndBuffers(void) {
    // 处理未完成的发送数据包
    if (ieee154e_vars.dataToSend != NULL) {
        schedule_indicateTx(&ieee154e_vars.asn, FALSE);
        ieee154e_vars.dataToSend->l2_retriesLeft--;

        if (ieee154e_vars.dataToSend->l2_retriesLeft == 0) {
            openserial_root_printf("exit:notif_sendDone");
            notif_sendDone(ieee154e_vars.dataToSend, E_FAIL);
        } else {
            ieee154e_vars.dataToSend->owner = COMPONENT_SIXTOP_TO_IEEE802154E;
        }
        ieee154e_vars.dataToSend = NULL;
    }

    // 处理接收的数据包
    if (ieee154e_vars.dataReceived != NULL) {
        notif_receive(ieee154e_vars.dataReceived);
        ieee154e_vars.dataReceived = NULL;
    }

    // 清理ACK缓冲区
    if (ieee154e_vars.ackToSend != NULL) {
        openqueue_freePacketBuffer(ieee154e_vars.ackToSend);
        ieee154e_vars.ackToSend = NULL;
    }
    if (ieee154e_vars.ackReceived != NULL) {
        openqueue_freePacketBuffer(ieee154e_vars.ackReceived);
        ieee154e_vars.ackReceived = NULL;
    }
}

/**
 * 处理cell统计和自主cell管理
 */
static void handleCellManagement(void) {
    slotinfo_element_t info;
    open_addr_t parentAddress;
    open_addr_t slotNeighbor;
    
    // 处理RX cell统计
    schedule_getSlotInfo(ieee154e_vars.slotOffset, &info);
    if (info.link_type == CELLTYPE_RX) {
        if (ieee154e_vars.receivedFrameFromParent) {
            if (icmpv6rpl_getPreferredParentEui64(&parentAddress)) {
                msf_updateCellsUsed(&parentAddress, CELLTYPE_RX);
            }
        }

        if (info.isAutoCell) {
            if (icmpv6rpl_getPreferredParentEui64(&parentAddress)) {
                if (schedule_hasNegotiatedCellToNeighbor(&parentAddress, CELLTYPE_RX) == FALSE) {
                    msf_updateCellsElapsed(&parentAddress, CELLTYPE_RX);
                }
            }
        } else {
            msf_updateCellsElapsed(&info.address, CELLTYPE_RX);
        }
    }
    ieee154e_vars.receivedFrameFromParent = FALSE;

    // 处理自动TX cell
    if (schedule_getSlottOffset() == ieee154e_vars.slotOffset &&
        schedule_getIsAutoCell() && schedule_getType() == CELLTYPE_TX) {
        
        schedule_getNeighbor(&slotNeighbor);
        if (openqueue_macGetUnicastPacket(&slotNeighbor) == NULL) {
            schedule_removeActiveSlot(
                ieee154e_vars.slotOffset,
                CELLTYPE_TX,
                TRUE,
                &slotNeighbor
            );
        }
    }
}

/**
 * 处理时隙结束的最终操作
 */
static void finalizeSlot(void) {
    // 改变状态
    changeState(S_SLEEP);

    // 设置串口禁止定时器
    if (ieee154e_vars.isSync == TRUE) {
        opentimers_scheduleAbsolute(
            ieee154e_vars.serialInhibitTimerId,
            DURATION_si,
            ieee154e_vars.startOfSlotReference,
            TIME_TICS,
            isr_ieee154e_inhibitStart
        );
    }

    
    /*  startRef
        &————————————————&
         ---------------: duration_si
                ^：getValue()
     */
    // 恢复串口活动
    //if (DURATION_si + ieee154e_vars.startOfSlotReference - opentimers_getValue() < ieee154e_vars.slotDuration) {
    if (opentimers_getValue() - ieee154e_vars.startOfSlotReference < DURATION_si){
        openserial_inhibitStop();
    }
}

bool ieee154e_isSynch(void) {
    return ieee154e_vars.isSync;
}
void endSlot(void) {
    // 1. 处理无线电和时间相关操作
    handleRadioAndTiming();
    
    // 2. 处理数据包和缓冲区清理
    handlePacketsAndBuffers();
    
    // 3. 处理cell管理和统计
    handleCellManagement();
    
    // 4. 结束时隙操作
    finalizeSlot();
}