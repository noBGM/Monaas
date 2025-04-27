// // usb_serial.c
// #include "04bsp_usbd_cdc_acm.h"
// #include "nrf52840.h"
// #include "sctimer.h"

// #include <stdint.h>
// #include "nrf.h"
// #include "nrfx_usbd.h"
// #include "app_usbd.h"
// #include "app_usbd_cdc_acm.h"
// #include "board.h"
// #include "leds.h"

// #define USB_BUFFER_SIZE 64
// #define CDC_ACM_COMM_INTERFACE  0
// #define CDC_ACM_DATA_INTERFACE  1

// // 全局变量
// static uint8_t m_rx_buffer[USB_BUFFER_SIZE];
// static uint8_t m_tx_buffer[USB_BUFFER_SIZE];
// static bool m_usb_connected = false;
// static bool m_rx_ready = false;
// static uint16_t m_rx_size = 0;
// static void cdc_acm_user_ev_handler(app_usbd_class_inst_t const * p_inst,
//                                   app_usbd_cdc_acm_user_event_t event);
// // CDC ACM实例
// APP_USBD_CDC_ACM_GLOBAL_DEF(m_app_cdc_acm,
//                            cdc_acm_user_ev_handler,
//                            CDC_ACM_COMM_INTERFACE,
//                            CDC_ACM_DATA_INTERFACE,
//                            NRF_DRV_USBD_EPIN2,
//                            NRF_DRV_USBD_EPIN1,
//                            NRF_DRV_USBD_EPOUT1,
//                            APP_USBD_CDC_COMM_PROTOCOL_AT_V250);

// // USB事件处理
// static void cdc_acm_user_ev_handler(app_usbd_class_inst_t const * p_inst,
//                                   app_usbd_cdc_acm_user_event_t event)
// {
//     switch (event)
//     {
//         case APP_USBD_CDC_ACM_USER_EVT_PORT_OPEN:
//             m_usb_connected = true;
//             app_usbd_cdc_acm_read(&m_app_cdc_acm, m_rx_buffer, USB_BUFFER_SIZE);
//             break;
            
//         case APP_USBD_CDC_ACM_USER_EVT_PORT_CLOSE:
//             m_usb_connected = false;
//             m_rx_ready = false;
//             break;
            
//         case APP_USBD_CDC_ACM_USER_EVT_RX_DONE:
//             m_rx_size = app_usbd_cdc_acm_rx_size(&m_app_cdc_acm);
//             m_rx_ready = true;
//             break;

//         case APP_USBD_CDC_ACM_USER_EVT_TX_DONE:
//             // 发送完成处理
//             break;
            
//         default:
//             break;
//     }
// }

// // USBD事件处理
// static void usbd_user_ev_handler(app_usbd_event_type_t event)
// {
//     switch (event)
//     {
//         case APP_USBD_EVT_POWER_DETECTED:
//             app_usbd_enable();
//             break;
            
//         case APP_USBD_EVT_POWER_REMOVED:
//             app_usbd_disable();
//             break;
            
//         case APP_USBD_EVT_POWER_READY:
//             app_usbd_start();
//             break;
            
//         default:
//             break;
//     }
// }

// // 发送数据
// bool usb_write(uint8_t* data, uint16_t length)
// {
//     if (!m_usb_connected || length > USB_BUFFER_SIZE) {
//         return false;
//     }
    
//     ret_code_t ret = app_usbd_cdc_acm_write(&m_app_cdc_acm, data, length);
//     return (ret == NRF_SUCCESS);
// }

// // 读取数据
// bool usb_read(uint8_t* data, uint16_t* length)
// {
//     if (!m_usb_connected || !m_rx_ready) {
//         return false;
//     }
    
//     // 复制接收到的数据
//     memcpy(data, m_rx_buffer, m_rx_size);
//     *length = m_rx_size;
    
//     // 重新开始接收
//     m_rx_ready = false;
//     app_usbd_cdc_acm_read(&m_app_cdc_acm, m_rx_buffer, USB_BUFFER_SIZE);
    
//     return true;
// }

// // USB初始化
// void usb_init(void)
// {
//     ret_code_t ret;
//     static const app_usbd_config_t usbd_config = {
//         .ev_state_proc = usbd_user_ev_handler
//     };
//     leds_sync_on();
//     ret = app_usbd_init(&usbd_config);
//     if (ret != NRF_SUCCESS) {
//         leds_error_on();  // 初始化失败，点亮错误LED
//         return;
//     }
//     leds_radio_on();
//     app_usbd_class_inst_t const * class_cdc_acm = 
//         app_usbd_cdc_acm_class_inst_get(&m_app_cdc_acm);
//     ret = app_usbd_class_append(class_cdc_acm);
//     if (ret != NRF_SUCCESS) {
//         leds_error_on();  // 添加类失败，点亮错误LED
//         return;
//     }
//     leds_radio_on();
//     app_usbd_power_events_enable();
    
//     leds_radio_on();
//     app_usbd_enable();
//     leds_debug_on();
//     app_usbd_start();

// }

// static void some_delay(void) {
//    volatile uint16_t delay;
//    for (delay=0xffff;delay>0;delay--);
// }
// // 在board.h中添加：
// #define PIN_USB_VBUS_DETECT    13   // P0.13 用于VBUS检测
// #define PIN_USB_PWR_CTRL       14   // P0.14 用于控制USB供电
// #define PIN_USB_DP             20   // P0.20 USB D+
// #define PIN_USB_DM             19   // P0.19 USB D-
// int mote_main(void)
// {
//     board_init();
//     usb_init();
//     leds_sync_on();
//     uint8_t test_data[] = "Hello USB\r\n";
//     uint8_t rx_data[USB_BUFFER_SIZE];
//     uint16_t rx_length;
    
//     // 主循环
//     while (1)
//     {
//         leds_radio_on();
//         // 处理USB事件
//         while (app_usbd_event_queue_process())
//         {
//             /* Nothing to do */
//         }
        
//         // 测试发送
//         if (m_usb_connected) {
//             usb_write(test_data, sizeof(test_data)-1);
//             some_delay();
//         }
//         leds_debug_on();
//         // 测试接收
//         if (usb_read(rx_data, &rx_length)) {
//             // 回显接收到的数据
//             usb_write(rx_data, rx_length);
//         }
//     }
// }

