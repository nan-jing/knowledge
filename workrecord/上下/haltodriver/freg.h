/*************************************************************************
	> File Name: freg.h
	> Author: ma6174
	> Mail: ma6174@163.com 
	> Created Time: 2017年03月08日 星期三 16时27分12秒
 ************************************************************************/

#ifndef ANDROID_FREG_INTERFACE_H
#define ANDROID_FREG_INTERFACE_H

#include <hardware/hardware.h>

#define FREG_HARDWARE_MODULE_ID "freg"
#define FREG_HARDWARE_DEVICE_ID "freg"

struct freg_module_t {
	struct hw_module_t common;
};

struct freg_device_t {
	struct hw_device_t common;
	int fd;
	int (*set_val)(struct freg_device_t *dev, int val);
	int (*get_val)(struct freg_device_t *dev, int* val);
};
#endif
