/**
\brief This program shows the use of the "radio" bsp module.

Since the bsp modules for different platforms have the same declaration, you
can use this project with any platform.

After loading this program, your board will switch on its radio on frequency
CHANNEL.

While receiving a packet (i.e. from the start of frame event to the end of
frame event), it will turn on its sync LED.

Every TIMER_PERIOD, it will also send a packet containing LENGTH_PACKET bytes
set to ID. While sending a packet (i.e. from the start of frame event to the
end of frame event), it will turn on its error LED.

\author Thomas Watteyne <watteyne@eecs.berkeley.edu>, August 2014.
*/

#include "stdio.h"
#include "stdint.h"
#include "string.h"
#include "board.h"
#include "radio.h"
#include "leds.h"
#include "sctimer.h"
#include "uart.h"
#include "bmx160.h"
#include "i2c.h"

//=========================== defines =========================================

#define LENGTH_PACKET   125+LENGTH_CRC  ///< maximum length is 127 bytes
#define LEN_PKT_TO_SEND 20+LENGTH_CRC
#define CHANNEL         26             ///< 11=2.405GHz 
#define TIMER_PERIOD    (0xffff>>4)    /// shift==13or14 stop working properly, as the speed is beyond 250kbps specified. //< 0xffff = 2s@32kHz
#define ID              '*'//0x99           ///< byte sent in the packets

uint8_t stringToSend[]  = "+002 Ptest.24.00.12.-010\n";

//=========================== variables =======================================

enum {
   APP_FLAG_START_FRAME = 0x01,
   APP_FLAG_END_FRAME   = 0x02,
   APP_FLAG_TIMER       = 0x04,
};

typedef enum {
   APP_STATE_TX         = 0x01,
   APP_STATE_RX         = 0x02,
} app_state_t;

typedef struct {
   uint8_t              num_startFrame;
   uint8_t              num_endFrame;
   uint8_t              num_timer;
    
   uint8_t              num_rx_startFrame;
   uint8_t              num_rx_endFrame;
} app_dbg_t;

app_dbg_t app_dbg;

typedef struct {
   volatile    uint8_t         uartDone;
   volatile    uint8_t         uartSendNow;
               uint8_t         uart_lastTxByteIndex;

               uint8_t         flags;
               app_state_t     state;
               uint8_t         packet[LENGTH_PACKET];
               uint8_t         packet_len;
               int8_t          rxpk_rssi;
               uint8_t         rxpk_lqi;
               bool            rxpk_crc;
} app_vars_t;

app_vars_t app_vars;

//=========================== prototypes ======================================

void     cb_startFrame(PORT_TIMER_WIDTH timestamp);
void     cb_endFrame(PORT_TIMER_WIDTH timestamp);
void     cb_timer(void);

void     cb_uart_tx_done(void);
uint8_t  cb_uart_rx(void);

//=========================== main ============================================

/**
\brief The program starts executing here.
*/
int mote_main(void) {
   uint8_t i;

   uint8_t freq_offset;
   uint8_t sign;
   uint8_t read;
   uint8_t seq=0;
   int16_t tmp;

   // clear local variables
   memset(&app_vars,0,sizeof(app_vars_t));

   // initialize board
   board_init();

   // setup UART
   uart_setCallbacks(cb_uart_tx_done,cb_uart_rx);
   uart_enableInterrupts();
    
   //bmx160
       // alway set address first
   i2c_set_addr(BMX160_ADDR);
   // should be 0xd8 for bmx160
   //app_vars.who_am_i = bmx160_who_am_i();    
   // configure bmx160 
   bmx160_acc_config(0x0c); 
   bmx160_gyr_config(0x0d);
   bmx160_mag_config(0x0b);
   bmx160_acc_range(0x8);
   bmx160_gyr_range(0x3);

   app_vars.uartDone = 1;

   // add callback functions radio
   radio_setStartFrameCb(cb_startFrame);
   radio_setEndFrameCb(cb_endFrame);

   // prepare packet
   app_vars.packet_len = sizeof(app_vars.packet);
   for (i=0;i<app_vars.packet_len;i++) {
       app_vars.packet[i] = ID;
   }

   // start bsp timer
   sctimer_set_callback(cb_timer);
   sctimer_setCompare(sctimer_readCounter()+TIMER_PERIOD);
   sctimer_enable();

   // prepare radio
   radio_rfOn();
   // freq type only effects on scum port
   radio_setFrequency(CHANNEL, FREQ_RX);

   // switch in RX by default
   radio_rxEnable();
   app_vars.state = APP_STATE_RX;

   // start by a transmit
   app_vars.flags |= APP_FLAG_TIMER;

   while (1) {

       // sleep while waiting for at least one of the flags to be set
       while (app_vars.flags==0x00) {
           board_sleep();
       }

       // handle and clear every flag
       while (app_vars.flags) {

           //==== APP_FLAG_START_FRAME (TX or RX)

           if (app_vars.flags & APP_FLAG_START_FRAME) {
               // start of frame

               switch (app_vars.state) {
                   case APP_STATE_RX:
                       // started receiving a packet

                       // led
                       leds_error_on();
                       break;
                   case APP_STATE_TX:
                       // started sending a packet

                       // led
                       leds_sync_on();
                   break;
               }

               // clear flag
               app_vars.flags &= ~APP_FLAG_START_FRAME;
           }

           //==== APP_FLAG_TIMER
            

           if (app_vars.flags & APP_FLAG_TIMER) {
               // timer fired

               if (app_vars.state==APP_STATE_RX) {
                   // stop listening
                   radio_rfOff();
                   // prepare packet
                   app_vars.packet_len = sizeof(app_vars.packet);
                   bmx160_read_9dof_data();
                   i = 0;
                   tmp = bmx160_read_gyr_x();
                   app_vars.packet[i++] = (uint8_t)((tmp>>8) & 0x00ff);
                   app_vars.packet[i++] = (uint8_t)((tmp>>0) & 0x00ff);
                   tmp = bmx160_read_gyr_y();
                   app_vars.packet[i++] = (uint8_t)((tmp>>8) & 0x00ff);
                   app_vars.packet[i++] = (uint8_t)((tmp>>0) & 0x00ff);
                   tmp = bmx160_read_gyr_z();
                   app_vars.packet[i++] = (uint8_t)((tmp>>8) & 0x00ff);
                   app_vars.packet[i++] = (uint8_t)((tmp>>0) & 0x00ff);

                   while (i<app_vars.packet_len) {
                       app_vars.packet[i++] = ID;
                   }

                   // start transmitting packet
                   radio_ble_loadPacket(app_vars.packet,LEN_PKT_TO_SEND);
                   radio_txEnable();
                   radio_txNow();

                   //app_vars.state = APP_STATE_TX;
               }

               // clear flag
               app_vars.flags &= ~APP_FLAG_TIMER;
           }
       }
   }
}

//=========================== callbacks =======================================

void cb_startFrame(PORT_TIMER_WIDTH timestamp) {
   // set flag
   app_vars.flags |= APP_FLAG_START_FRAME;

   // update debug stats
   app_dbg.num_startFrame++;

   if (app_vars.state == APP_STATE_RX) {
       app_dbg.num_rx_startFrame++;
   }
}

void cb_endFrame(PORT_TIMER_WIDTH timestamp) {
   // set flag
   app_vars.flags |= APP_FLAG_END_FRAME;

   // update debug stats
   app_dbg.num_endFrame++;

   if (app_vars.state == APP_STATE_RX) {
       app_dbg.num_rx_endFrame++;
   }
}

void cb_timer(void) {
   // set flag
   app_vars.flags |= APP_FLAG_TIMER;

   // update debug stats
   app_dbg.num_timer++;

   sctimer_setCompare(sctimer_readCounter()+TIMER_PERIOD);
}

void cb_uart_tx_done(void) {
   app_vars.uart_lastTxByteIndex++;
   if (stringToSend[app_vars.uart_lastTxByteIndex]!='\0') {
       uart_writeByte(stringToSend[app_vars.uart_lastTxByteIndex]);
   } else {
       app_vars.uartDone = 1;
   }
}

uint8_t cb_uart_rx(void) {
   uint8_t byte;

   // toggle LED
   leds_error_toggle();

   // read received byte
   byte = uart_readByte();

   // echo that byte over serial
   uart_writeByte(byte);

   return 0;
}
