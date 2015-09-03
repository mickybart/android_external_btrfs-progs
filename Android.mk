LOCAL_PATH:= $(call my-dir)

#include $(call all-subdir-makefiles)

CFLAGS := -g -O1 -Wall -D_FORTIFY_SOURCE=2 -include config.h -DBTRFS_FLAT_INCLUDES -D_XOPEN_SOURCE=700 -fno-strict-aliasing -fPIC -DPLATFORM_ANDROID=1

STATIC_CFLAGS := $(CFLAGS) -ffunction-sections -fdata-sections

btrfs_shared_libraries := libext2_uuid libext2_blkid

btrfs_static_libraries := libext2_uuid_static libext2_blkid
btrfs_system_static_libraries := libc libcutils

objects := ctree.c disk-io.c radix-tree.c extent-tree.c print-tree.c \
          root-tree.c dir-item.c file-item.c inode-item.c inode-map.c \
          extent-cache.c extent_io.c volumes.c utils.c repair.c \
          qgroup.c raid6.c free-space-cache.c list_sort.c props.c \
          ulist.c qgroup-verify.c backref.c string-table.c task-utils.c \
          inode.c file.c find-root.c
cmds_objects := cmds-subvolume.c cmds-filesystem.c cmds-device.c cmds-scrub.c \
               cmds-inspect.c cmds-balance.c cmds-send.c cmds-receive.c \
               cmds-quota.c cmds-qgroup.c cmds-replace.c cmds-check.c \
               cmds-restore.c cmds-rescue.c chunk-recover.c super-recover.c \
               cmds-property.c cmds-fi-usage.c
libbtrfs_objects := send-stream.c send-utils.c rbtree.c btrfs-list.c crc32c.c \
                   uuid-tree.c utils-lib.c rbtree-utils.c
libbtrfs_headers := send-stream.h send-utils.h send.h rbtree.h btrfs-list.h \
                   crc32c.h list.h kerncompat.h radix-tree.h extent-cache.h \
                   extent_io.h ioctl.h ctree.h btrfsck.h version.h
TESTS := fsck-tests.sh convert-tests.sh
blkid_objects := partition/ superblocks/ topology/


# external/e2fsprogs/lib is needed for uuid/uuid.h
common_C_INCLUDES := $(LOCAL_PATH) external/e2fsprogs/lib/ external/liblzo/include/ external/zlib/

#----------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(libbtrfs_objects)
LOCAL_CFLAGS := $(STATIC_CFLAGS)
LOCAL_MODULE := libbtrfs
LOCAL_C_INCLUDES := $(common_C_INCLUDES)
include $(BUILD_STATIC_LIBRARY)

#----------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_MODULE := btrfs

# btrfs is used in recovery: must be static.
LOCAL_FORCE_STATIC_EXECUTABLE := true

# Recovery needs it also, so it must go into root/sbin/.
# Directly generating into the recovery/root/sbin gets clobbered
# when the recovery image is being made.
# LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT_SBIN)

LOCAL_SRC_FILES := \
		$(objects) \
		$(cmds_objects) \
		$(libbtrfs_objects) \
		btrfs.c \
		help.c

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(STATIC_CFLAGS)
LOCAL_STATIC_LIBRARIES := $(btrfs_static_libraries) liblzo-static libz $(btrfs_system_static_libraries)

LOCAL_EXPORT_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)

#----------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_MODULE := mkfs.btrfs

# mkfs.btrfs is used in recovery: must be static.
LOCAL_FORCE_STATIC_EXECUTABLE := true

# Recovery needs it also, so it must go into root/sbin/.
# Directly generating into the recovery/root/sbin gets clobbered
# when the recovery image is being made.
# LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT_SBIN)

LOCAL_SRC_FILES := \
                $(objects) \
		$(libbtrfs_objects) \
                mkfs.c

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(STATIC_CFLAGS)
LOCAL_STATIC_LIBRARIES := $(btrfs_static_libraries) liblzo-static $(btrfs_system_static_libraries)

LOCAL_EXPORT_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)

#---------------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_MODULE := btrfstune
LOCAL_SRC_FILES := \
                $(objects) \
                btrfstune.c

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(STATIC_CFLAGS)
LOCAL_SHARED_LIBRARIES := $(btrfs_shared_libraries)
LOCAL_STATIC_LIBRARIES := libbtrfs liblzo-static
LOCAL_SYSTEM_SHARED_LIBRARIES := libc libcutils

LOCAL_EXPORT_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)
#--------------------------------------------------------------
