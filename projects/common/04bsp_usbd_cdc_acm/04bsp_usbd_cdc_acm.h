// usb_serial.h
#ifndef USB_SERIAL_H
#define USB_SERIAL_H

#include <stdint.h>
#include "app_usbd.h"
#include "app_usbd_cdc_acm.h"

void usb_serial_init(void);
bool usb_serial_send(uint8_t* data, uint16_t length);
bool usb_serial_connected(void);

#endif