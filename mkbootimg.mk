LOCAL_PATH := $(call my-dir)

# custom recovery path, prebuilt recovery must be downloaded here
# path can NOT be changed (w/o changing build/make, too) !
BOARD_PREBUILT_RECOVERY := /tmp/recovery/IMAGES/recovery.img

ROOT_BOOT_BIN := $(OUT_DIR)/.magisk/boot_patch.sh

BOARD_CUSTOM_BOOTIMG := true

# BOOT.IMG
ifeq ($(ROOTBOOT),true)
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(AVBTOOL) $(INTERNAL_BOOTIMAGE_FILES) $(BOARD_AVB_BOOT_KEY_PATH)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	@echo "++++  PRE-ROOTing BOOT image!!!  ++++"
	@/bin/bash $(ROOT_BOOT_BIN) $$PWD/$@
	$(hide) $(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(BOARD_BOOTIMAGE_PARTITION_SIZE)))
	@echo "++++  Add hash footer to BOOT image  ++++"
	$(hide) $(AVBTOOL) add_hash_footer \
          --image $(OUT_DIR)/.magisk/new-boot.img \
          --partition_size $(BOARD_BOOTIMAGE_PARTITION_SIZE) \
          --partition_name boot $(INTERNAL_AVB_BOOT_SIGNING_ARGS) \
          $(BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS)
	@cp -v $(OUT_DIR)/.magisk/new-boot.img  $(PRODUCT_OUT)/boot.img
else
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(AVBTOOL) $(INTERNAL_BOOTIMAGE_FILES) $(BOARD_AVB_BOOT_KEY_PATH)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(BOARD_BOOTIMAGE_PARTITION_SIZE)))
	@echo "++++  Add hash footer to BOOT image  ++++"
	$(hide) $(AVBTOOL) add_hash_footer \
          --image $@ \
          --partition_size $(BOARD_BOOTIMAGE_PARTITION_SIZE) \
          --partition_name boot $(INTERNAL_AVB_BOOT_SIGNING_ARGS) \
          $(BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS)
endif

# RECOVERY.IMG
$(INSTALLED_RECOVERYIMAGE_TARGET):
	@echo "++++  Add hash footer to PREBUILT RECOVERY  ++++"
	$(AVBTOOL) add_hash_footer \
	    --image $(BOARD_PREBUILT_RECOVERY) \
	    --partition_size $(BOARD_RECOVERYIMAGE_PARTITION_SIZE) \
	    --partition_name recovery $(INTERNAL_AVB_RECOVERY_SIGNING_ARGS) \
	    $(BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS)
	@echo "++++  Copying PREBUILT RECOVERY to $(PRODUCT_OUT)  ++++"
	@cp $(BOARD_PREBUILT_RECOVERY) $(PRODUCT_OUT)/recovery.img
