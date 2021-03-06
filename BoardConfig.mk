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
BOARD_USES_GENERIC_AUDIO := false

TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := false
TARGET_NO_RADIOIMAGE := true
TARGET_NO_RECOVERY := false
TARGET_NO_PREINSTALL := true

# Board properties
TARGET_BOARD_PLATFORM := omap3
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_GLOBAL_CFLAGS += -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp
TARGET_GLOBAL_CPPFLAGS += -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp
TARGET_OMAP3 := true
COMMON_GLOBAL_CFLAGS += -DTARGET_OMAP3 -DOMAP_COMPAT -DBINDER_COMPAT

## fix crash on 2.6.29 kernels on ARMv7A on several devices
ARCH_ARM_HAVE_ARMV7A_BUG := true
## also have to fix typo in external/v8/Android.mk, fixed already

### as i have read we have the tls register
## Quarx said that option get bootloop on defy
ARCH_ARM_HAVE_TLS_REGISTER := false
### will uncomment, when have test enough

TARGET_BOOTLOADER_BOARD_NAME := sholest

## BUILD OPTIONS:
TARGET_PREBUILT_KERNEL := device/motorola/sholest/kernel 

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
WPA_SUPPL_WITH_SIGNAL_POLL  := true
# CM9
WIFI_AP_DRIVER_MODULE_PATH  := "/system/lib/modules/tiap_drv.ko"
WIFI_AP_DRIVER_MODULE_NAME  := tiap_drv
WIFI_AP_FIRMWARE_LOADER     := wlan_ap_loader
WIFI_AP_DRIVER_MODULE_ARG   := ""
BOARD_HOSTAPD_DRIVER        := true
BOARD_HOSTAPD_DRIVER_NAME   := wilink

BOARD_USE_YUV422I_DEFAULT_COLORFORMAT := true
BOARD_EGL_CFG := device/motorola/sholest/egl.cfg
#BOARD_CUSTOM_USB_CONTROLLER := ../../device/motorola/sholest/UsbController.cpp

BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM :=true
#BOARD_GPS_LIBRARIES := libgps
BOARD_USES_GPSSHIM := false

BOARD_BOOTIMAGE_PARTITION_SIZE := $(call image-size-from-data-size,0x00380000)
BOARD_RECOVERYIMAGE_PARTITION_SIZE := $(call image-size-from-data-size,0x00500000)
BOARD_SYSTEMIMAGE_PARTITION_SIZE := $(call image-size-from-data-size,0x0afa0000)
BOARD_USERDATAIMAGE_PARTITION_SIZE := $(call image-size-from-data-size,0x0cac0000)
BOARD_FLASH_BLOCK_SIZE := 131072

USE_OPENGL_RENDERER := true
BOARD_WITHOUT_HW_COMPOSER := true
ENABLE_WEBGL := true
HARDWARE_OMX := true
BUILD_WITH_TI_AUDIO := 1
BUILD_PV_VIDEO_ENCODERS := 1
BOARD_USE_YUV422I_DEFAULT_COLORFORMAT := true

TARGET_USE_OMAP_COMPAT := true
TARGET_SKIA_USE_MORE_MEMORY := false
BOARD_USE_USB_MASS_STORAGE_SWITCH := true

ENABLE_SENSORS_COMPAT := true
BOARD_USES_AUDIO_LEGACY := true
TARGET_PROVIDES_LIBAUDIO := true
BOARD_USE_LEGACY_TOUCHSCREEN := true
#BOARD_CUSTOM_USB_CONTROLLER := ../../device/motorola/sholest/UsbController.cpp
BOARD_HAS_VIBRATOR_IMPLEMENTATION := ../../device/motorola/sholest/vibrator.c
TARGET_CUSTOM_BLUEDROID := ../../../device/motorola/sholest/bluedroid.c

BOARD_USES_CAMERASHIM := true
BOARD_CAMERA_LIBRARIES := libcamera
BOARD_CAMERA_MOTOROLA_COMPAT := true
BOARD_USE_FROYO_LIBCAMERA := true

BOARD_MASS_STORAGE_FILE_PATH := "/sys/devices/platform/usb_mass_storage/lun0/file"
TARGET_USE_CUSTOM_LUN_FILE_PATH := "/sys/devices/platform/usb_mass_storage/lun0/file"

# Recovery
BOARD_HAS_NO_MISC_PARTITION := true
BOARD_RECOVERY_IGNORE_BOOTABLES := true
BOARD_HAS_SMALL_RECOVERY := true
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_NEVER_UMOUNT_SYSTEM := true
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := yaffs2
TARGET_USERIMAGES_USE_EXT4 := false


TARGET_RECOVERY_PRE_COMMAND := "echo 1 > /cache/.boot_to_or; sync;"
TARGET_RECOVERY_PRE_COMMAND_CLEAR_REASON := true

# Override cyanogen squisher to customize our update zip package
TARGET_CUSTOM_RELEASETOOL := ./device/motorola/sholest/releasetools/squisher
TARGET_PROVIDES_RELEASETOOLS := true
TARGET_NEEDS_MOTOROLA_HIJACK := true
