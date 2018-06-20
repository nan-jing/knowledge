/*************************************************************************
	> File Name: cjzang.h
	> Author: ma6174
	> Mail: ma6174@163.com 
	> Created Time: 2017年03月03日 星期五 15时49分21秒
 ************************************************************************/

//#include<iostream>
//#using namespace std;
#ifndef __FAKE_REG_H_
#define __FAKE_REG_H_

#include <linux/cdev.h>
#include <linux/semaphore.h>

#define FREG_DEVICE_NODE_NAME "freg"
#define FREG_DEVICE_FILE_NAME "freg"
#define FREG_DEVICE_PROC_NAME "freg"
#define FREG_DEVICE_CLASS_NAME "freg"

struct fake_reg_dev {
	int val;
	struct semaphore sem;
	struct cdev dev;
};
#endif
