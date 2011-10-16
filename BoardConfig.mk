# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This file sets variables that control the way modules are built
# thorughout the system. It should not be used to conditionally
# disable makefiles (the proper mechanism to control what gets
# included in a build is to use PRODUCT_PACKAGES in a product
# definition file).
#

# WARNING: This line must come *before* including the proprietary
# variant, so that it gets overwritten by the parent (which goes
# against the traditional rules of inheritance).
USE_CAMERA_STUB := false

# inherit from the proprietary version

BOARD_USES_GENERIC_AUDIO := false
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true
TARGET_NO_RADIOIMAGE := true
TARGET_BOARD_PLATFORM := omap3
TARGET_OTA_NO_KERNEL := true
TARGET_OTA_EXTRA_ARGS := -e device/motorola/sholest/install-orbootstrap --no_kernel true --no_recovery true --backup false --override_device sholest
#TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI := armeabi-v7l
TARGET_CPU_ABI2 := armeabi
#TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_ARCH_VARIANT := armv7-l-neon
#TARGET_GLOBAL_CFLAGS += -mtune=cortex-a8
TARGET_GLOBAL_CFLAGS += -mtune=cortex-a8 -mfpu=neon
#TARGET_GLOBAL_CPPFLAGS += -mtune=cortex-a8
TARGET_GLOBAL_CPPFLAGS += -mtune=cortex-a8 -mfpu=neon
TARGET_OMAP3 := true
COMMON_GLOBAL_CFLAGS += -DTARGET_OMAP3
TARGET_BOOTLOADER_BOARD_NAME := sholest
# Wifi related defines
BOARD_WLAN_DEVICE           := wl1271
WPA_SUPPLICANT_VERSION      := VER_0_6_X
BOARD_WPA_SUPPLICANT_DRIVER := CUSTOM
WIFI_DRIVER_MODULE_PATH     := "/system/lib/modules/tiwlan_drv.ko"
WIFI_DRIVER_MODULE_NAME     := tiwlan_drv
WIFI_DRIVER_FW_STA_PATH     := "/system/etc/wifi/fw_wlan1271.bin"
WIFI_FIRMWARE_LOADER        := wlan_loader
PRODUCT_WIRELESS_TOOLS      := true
BOARD_SOFTAP_DEVICE         := wl1271
AP_CONFIG_DRIVER_WILINK     := true
WIFI_DRIVER_FW_AP_PATH      := "/system/etc/wifi/fw_tiwlan_ap.bin"
WPA_SUPPL_APPROX_USE_RSSI   := true

BOARD_USES_ECLAIR_LIBAUDIO := true
#BOARD_BOOTIMAGE_PARTITION_SIZE := 0x00380000
#BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x00480000
#BOARD_SYSTEMIMAGE_PARTITION_SIZE := 0x0afa0000   # limited so we enforce room to grow
#BOARD_USERDATAIMAGE_PARTITION_SIZE := 0x0c520000
#BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_MAX_SIZE := $(call image-size-from-data-size,0x00380000)
BOARD_RECOVERYIMAGE_MAX_SIZE := $(call image-size-from-data-size,0x00500000)
BOARD_SYSTEMIMAGE_MAX_SIZE := $(call image-size-from-data-size,0x0afa0000)
BOARD_USERDATAIMAGE_MAX_SIZE := $(call image-size-from-data-size,0x0cac0000)
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_USE_FROYO_LIBCAMERA := true
HARDWARE_OMX := true
BUILD_WITH_TI_AUDIO := 1
BUILD_PV_VIDEO_ENCODERS := 1
BOARD_HAVE_BLUETOOTH := true
BOARD_EGL_CFG := device/motorola/sholest/egl.cfg
# Changes related to bootmenu
# Recovery
BOARD_HAS_NO_MISC_PARTITION := true
BOARD_RECOVERY_IGNORE_BOOTABLES := true
BOARD_HAS_SMALL_RECOVERY := true
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true

#TARGET_RECOVERY_UI_LIB := librecovery_ui_sholes librecovery_ui_generic

BOARD_NEVER_UMOUNT_SYSTEM := true
#TARGET_RECOVERY_UI_LIB := librecovery_ui_generic
#TARGET_RECOVERY_UPDATER_LIBS += librecovery_updater_generic

BOARD_GPS_LIBRARIES := libgps
BOARD_USES_GPSSHIM := true

#TARGET_NO_KERNEL := true
# Jordan need 2nd-init binary from motorola common
TARGET_NEEDS_MOTOROLA_HIJACK := true
#TARGET NO KERNEL from Quarx advice:

BOARD_NO_RGBX_8888 := true
BOARD_USE_YUV422I_DEFAULT_COLORFORMAT := true 
# Prebuilt boot.img

LOCAL_KERNEL := device/motorola/sholest/kernel
PRODUCT_COPY_FILES += \
	$(LOCAL_KERNEL):kernel

 #In nighly builds only
# Override cyanogen squisher to customize our update zip package
 TARGET_CUSTOM_RELEASETOOL := ./device/motorola/sholest/releasetools/squisher
#
BOARD_USE_USB_MASS_STORAGE_SWITCH := true
