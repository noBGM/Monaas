/**
\brief This is a program which shows how to use the bsp modules for the board
       and UART.

\note: Since the bsp modules for different platforms have the same declaration,
       you can use this project with any platform.

Load this program on your board. Open a serial terminal client (e.g. PuTTY or
TeraTerm):
- You will read "Hello World!" printed over and over on your terminal client.
- when you enter a character on the client, the board echoes it back (i.e. you
  see the character on the terminal client) and the "ERROR" led blinks.

\author Thomas Watteyne <watteyne@eecs.berkeley.edu>, February 2012
*/

#include "stdint.h"
#include "stdio.h"
#include "string.h"
// bsp modules required
#include "board.h"
#include "uart.h"
#include "sctimer.h"
#include "leds.h"

//=========================== defines =========================================

#define SCTIMER_PERIOD     0xffff // 0xffff@32kHz = 2s
uint8_t stringToSend[]       = "Hello, World!\r\n";
uint8_t stringRx[20];
uint8_t indeX=0;
//=========================== variables =======================================

typedef struct {
   uint8_t uart_lastTxByteIndex;   // UART最后发送的字节索引
   volatile uint8_t uartDone;      // UART发送完成标志位
   volatile uint8_t uartSendNow;   // UART立即发送标志位
   volatile uint8_t uartRxDone;    // UART接收完成标志位
} app_vars_t;

app_vars_t app_vars;

//=========================== prototypes ======================================

void cb_compare(void);              // SCTimer比较回调函数
void cb_uartTxDone(void);           // UART发送完成回调函数
uint8_t cb_uartRxCb(void);          // UART接收回调函数
void uartTx(void);                  // UART发送函数
uint8_t uartRx(void);               // UART接收函数
//=========================== main ============================================

/**
\brief The program starts executing here.
*/
int mote_main(void) {
   
   // clear local variable
   memset(&app_vars,0,sizeof(app_vars_t));
    
   app_vars.uartSendNow = 1;
   
   // initialize the board
   board_init();
   
   // setup UART
   uart_setCallbacks(uartTx,uartRx);
   uart_enableInterrupts();
   
   // setup sctimer
   sctimer_set_callback(cb_compare);
   sctimer_setCompare(sctimer_readCounter()+SCTIMER_PERIOD);
   
   while(1) {
      
      // wait for timer to elapse
      while (app_vars.uartSendNow==0 );
      app_vars.uartSendNow = 0;
      
      // send string over UART
      app_vars.uartDone              = 0;
      app_vars.uart_lastTxByteIndex  = 0;
//    while (app_vars.uartRxDone == 0 );
      uart_writeByte(stringToSend[app_vars.uart_lastTxByteIndex]);
      while(app_vars.uartDone==0);
   }
}

//=========================== callbacks =======================================

void cb_compare(void) {
   
   // have main "task" send over UART
   app_vars.uartSendNow = 1;
   
   // schedule again
   sctimer_setCompare(sctimer_readCounter()+SCTIMER_PERIOD);
}

void cb_uartTxDone(void) {
   app_vars.uart_lastTxByteIndex++;
   if (app_vars.uart_lastTxByteIndex<sizeof(stringToSend)) {
      uart_writeByte(stringToSend[app_vars.uart_lastTxByteIndex]);
   } else {
      app_vars.uartDone = 1;
   }
}

uint8_t cb_uartRxCb(void) {
   uint8_t byte;
   
   // toggle LED
   leds_error_toggle();
   
   // read received byte
   byte = uart_readByte();
   
   // echo that byte over serial
   uart_writeByte(byte);
   
   return 0;
}

void uartTx(void) {
   app_vars.uart_lastTxByteIndex++;
   if (stringToSend[app_vars.uart_lastTxByteIndex]!='\0') {
      uart_writeByte(stringToSend[app_vars.uart_lastTxByteIndex]);
   } else {
      app_vars.uartDone = 1;
   }
}


uint8_t uartRx(void) {
   uint8_t byte;
   
   // toggle LED
   leds_error_toggle();
   
   // read received byte
   byte = uart_readByte();
   if (byte == '\r'){
      stringRx[indeX]='\r';
      stringRx[indeX+1]='\n';
      stringRx[indeX+2]='\0';
      strcpy(stringToSend,stringRx); 
      indeX = 0;
      app_vars.uartRxDone=1;
   }else{
      stringRx[indeX++]=byte;
   }
   // echo that byte over serial
  // uart_writeByte(byte);
   
   return 0;
}