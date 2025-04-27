/**
\brief registers address mapping of bmx160 sensor.

\author Tengfei Chang <tengfei.chang@gmail.com>, Nov 2021.
*/

#include "stdint.h"

//=========================== define ==========================================

#define BMX160_ADDR 0x68
#define BMP388_ADDR 0x76
//---- register addresses

#define BMX160_REG_ADDR_CHIPID      0x00
#define BMX160_REG_ADDR_ERR_REG     0x02
#define BMX160_REG_ADDR_PMU_STATUS  0x03


#define BMP388_REG_PWR_CTRL         0x1B 
#define BMP388_EN_SENSOR_ALL        0x33 //0x00110011 normal mode & temp and press sensor enabled

// sensor data

#define BMP388_REG_ALL_DATA         0x04


//=========================== variables =======================================

//=========================== prototypes ======================================

//=========================== public ==========================================

// admin

void bmp388_read_data(void);
void bmp388_set_cmd(uint8_t,uint8_t);
int8_t bmp388_read_subdata(void);
//=========================== private =========================================