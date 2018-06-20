/*************************************************************************
	> File Name: freg.cpp
	> Author: ma6174
	> Mail: ma6174@163.com
	> Created Time: 2017年a03月08日 星期三 16时32分02秒
*/
#define LOG_NDEBUG 0
#define LOG_TAG "FregHALStub"
#include <utils/Log.h>

#include <inttypes.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <dirent.h>
#include <unistd.h>

#include <string.h>

#include <cutils/atomic.h>
#include <cutils/properties.h> // for property_get

#include <utils/misc.h>

#include <binder/IPCThreadState.h>
#include <binder/IServiceManager.h>
#include <binder/MemoryHeapBase.h>
#include <binder/MemoryBase.h>
#include <gui/Surface.h>
#include <utils/Errors.h>  // for status_t
#include <utils/String8.h>
#include <utils/SystemClock.h>
#include <utils/Timers.h>
#include <utils/Vector.h>

#include <utils/Log.h>
#include <hardware/hardware.h>
#include <hardware/freg.h>

#include <fcntl.h>
#include <errno.h>

#include <cutils/atomic.h>

#define DEVICE_NAME "/dev/freg"
#define MODULE_NAME "Freg"
#define MODULE_AUTHOR "cjzang"

static int freg_device_open(const struct hw_module_t *module, const char *id, struct hw_device_t **device);
static int freg_device_close(struct hw_device_t *device);

static int freg_get_val(struct freg_device_t *dev, int *val);
static int freg_set_val(struct freg_device_t *dev, int val);

static struct hw_module_methods_t freg_module_methods = {
	.open = freg_device_open,
};

struct freg_module_t HAL_MODULE_INFO_SYM = {
	common : {
		tag : HARDWARE_MODULE_TAG,
		version_major : 1,
		version_minor : 0,
		id : FREG_HARDWARE_MODULE_ID,
		name : MODULE_NAME,
		author : MODULE_AUTHOR,
		methods : &freg_module_methods,
	},
};

static int freg_device_open(const struct hw_module_t *module, const char *id, struct hw_device_t **device) {
	if (! strcmp(id, FREG_HARDWARE_DEVICE_ID)) {
		struct freg_device_t *dev;
		dev = (struct freg_device_t *)malloc(sizeof(struct freg_device_t));
		if (! dev) {
			ALOGE("Fail to alloc space for freg_device_t");
			return -EFAULT;
		}
		memset(dev, 0, sizeof(struct freg_device_t));
		dev->common.tag = HARDWARE_DEVICE_TAG;
		dev->common.version = 0;
		dev->common.module = (hw_module_t*)module;
		dev->common.close = freg_device_close;
		dev->set_val = freg_set_val;
		dev->get_val = freg_get_val;

		if ((dev->fd = open(DEVICE_NAME, 0, O_RDWR)) == -1) {
			ALOGE("Fail TO open device");
			free(dev);
			return -EFAULT;
		}

		*device = &(dev->common);
		ALOGI("Open device /dev/freg success");
		return 0;
	}

	return -EFAULT;
}

static int freg_device_close(struct hw_device_t *device){
	struct freg_device_t *freg_device = (struct freg_device_t *)device;
	if (freg_device) {
		close(freg_device->fd);
		free(freg_device);
	}

	return 0;
}

static int freg_get_val(struct freg_device_t *dev, int *val) {
	if (! dev) {
		ALOGE("dev is NULL");
		return -EFAULT;
	}

	if (!val) {
		ALOGE("val is NULL");
		return -EFAULT;
	}
	read(dev->fd, val, sizeof(*val));

	ALOGI("Get value %d from device file /dev/freg", *val);

	return 0;
}

static int freg_set_val(struct freg_device_t *dev, int val) {
	if (!dev) {
		ALOGE("dev is NULL");
		return -EFAULT;
	}

	write(dev->fd, &val, sizeof(val));
	return 0;
}
