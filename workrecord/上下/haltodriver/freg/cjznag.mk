LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE_TAG := optional
LOCAL_PRELINK_MODULE := false
LOCAL_C_INCLUDES := hardware/libhardware
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_SHARED_LIBRARIES := liblog
LOCAL_SRC_FILES := freg.cpp
LOCAL_MODULE := freg.default

include $(BUILD_SHARD_LIBRARY)


