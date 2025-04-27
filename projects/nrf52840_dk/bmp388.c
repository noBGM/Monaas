

#include "i2c.h"
#include "bmp388.h"

typedef struct{
    int8_t pres_x;
    int8_t pres_1;
    int8_t pres_2;

    int8_t temp_x;
    int8_t temp_1;
    int8_t temp_2;
}bmp388_data_t;

typedef struct {
    
    bmp388_data_t bmp388_data;

}bmp388_var_t;

bmp388_var_t bmp388_var;

void bmp388_set_cmd(uint8_t add,uint8_t cmd) {
    i2c_write_bytes(add, &cmd, 1);
}

int8_t bmp388_read_subdata(void) {
    return bmp388_var.bmp388_data.pres_1;
}

void bmp388_read_data(void) {

    uint8_t pmu_status;
    
    // enable both pressure and temprature sensors
    do {
        bmp388_set_cmd(BMP388_REG_PWR_CTRL,BMP388_EN_SENSOR_ALL);
        i2c_read_bytes(BMP388_REG_PWR_CTRL, &pmu_status, 1);
    } while ((pmu_status & 0x33) != 0x33); 

    // wait until pmu status are correct
    //       acc_normal gyr_normal mag_if_normal
    // 0xb10 01         01         01 = 0x95
    
    i2c_read_bytes(BMP388_REG_ALL_DATA, (uint8_t*)(&bmp388_var.bmp388_data), sizeof(bmp388_data_t));
}