#
# Copyright (C) 2019 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from hotdog device
$(call inherit-product, device/oneplus/hotdog/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := lineage_hotdog
PRODUCT_DEVICE := hotdog
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := OnePlus 7T Pro
PRODUCT_MANUFACTURER := OnePlus

PRODUCT_AAPT_CONFIG := xxxhdpi
PRODUCT_AAPT_PREF_CONFIG := xxxhdpi
PRODUCT_CHARACTERISTICS := nosdcard

# Boot animation
TARGET_SCREEN_HEIGHT := 3120
TARGET_SCREEN_WIDTH := 1440

# Build info
BUILD_FINGERPRINT := "OnePlus/OnePlus7TPro_EEA/OnePlus7TPro:10/QKQ1.190716.003/1910120055:user/release-keys"
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_DEVICE=OnePlus7TPro \
    PRODUCT_NAME=OnePlus7TPro \
    PRIVATE_BUILD_DESC="OnePlus7TPro_EEA-user 10 QKQ1.190716.003 1910120055 release-keys"

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

# custom OTA server (when not an official build)
ifeq ($(LINEAGE_BUILDTYPE),"UNOFFICIAL")
PRODUCT_PROPERTY_OVERRIDES += \
    lineage.updater.uri=http://sfxota.binbash.rocks:8009/e-os/a10/api/v1/{device}/{type}/{incr}
endif
ifeq ($(LINEAGE_BUILDTYPE),"CUSTOM")
PRODUCT_PROPERTY_OVERRIDES += \
    lineage.updater.uri=http://sfxota.binbash.rocks:8009/e-os/a10/api/v1/{device}/{type}/{incr}
endif

# Enable extendrom
$(call inherit-product-if-exists, vendor/extendrom/config/common.mk)
