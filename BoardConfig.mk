#
# Copyright (C) 2018-2019 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
-include device/oneplus/sm8150-common/BoardConfigCommon.mk

BOARD_VENDOR := oneplus
DEVICE_PATH := device/oneplus/hotdog

# Display
TARGET_SCREEN_DENSITY := 560

# Kernel
TARGET_KERNEL_CONFIG := vendor/sm8150-perf_defconfig

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 25165824
BOARD_ODMIMAGE_PARTITION_SIZE := 104857600
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 100663296
BOARD_USERDATAIMAGE_PARTITION_SIZE := 115601780736
ifneq ($(WITH_GMS),true)
BOARD_PRODUCTIMAGE_EXTFS_INODE_COUNT := -1
BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 1887436800
BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := -1
BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 1887436800
endif
BOARD_SUPER_PARTITION_SIZE := 15032385536
BOARD_SUPER_PARTITION_GROUPS := oneplus_dynamic_partitions
BOARD_ONEPLUS_DYNAMIC_PARTITIONS_PARTITION_LIST := odm product system vendor
BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE := 7511998464
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_PRODUCT := product
BOARD_USES_RECOVERY_AS_BOOT := false

# dedup to save space
BOARD_EXT4_SHARE_DUP_BLOCKS := true

# Bluetooth
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(DEVICE_PATH)/bluetooth/include

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom

# Treble
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml

# Fingerprint
SOONG_CONFIG_ONEPLUS_MSMNILE_FOD_POS_X = 610
SOONG_CONFIG_ONEPLUS_MSMNILE_FOD_POS_Y = 2618
SOONG_CONFIG_ONEPLUS_MSMNILE_FOD_SIZE = 220

# Sensors
SOONG_CONFIG_ONEPLUS_MSMNILE_SENSORS_ALS_POS_X := 900
SOONG_CONFIG_ONEPLUS_MSMNILE_SENSORS_ALS_POS_Y := 260

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_VBMETA_SYSTEM := system
#BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_ALGORITHM := SHA256_RSA2048
# created by: openssl pkcs8 -in releasekey.pk8 -inform DER -out releasekey.key -nocrypt
BOARD_AVB_KEY_PATH := user-keys/releasekey.key

# special handling when UNOFFICIAL or CUSTOM build
CURBTYPE=$(shell echo $$EOS_RELEASE_TYPE)
ifeq ($(CURBTYPE),UNOFFICIAL)
# set sfX OTA server
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
endif
ifeq ($(CURBTYPE),CUSTOM)
# add custom prebuilt recovery
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/mkbootimg.mk
# set sfX OTA server (diff for root or not rooted)
ROOTBOOT=$(shell echo $$EXTENDROM_PREROOT_BOOT)
ifeq ($(ROOTBOOT),true)
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system_rooted.prop
else
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
endif # ROOTBOOT
endif # CUSTOM
