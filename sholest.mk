#
# Copyright (C) 2011 The Android Open Source Project
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

#
# This is the product configuration for a generic Motorola Milestone XT720 (sholest)
#

# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_eu_supl.mk)

## (3)  Finally, the least specific parts, i.e. the non-GSM-specific aspects
PRODUCT_PROPERTY_OVERRIDES += \
	ro.com.google.locationfeatures=1 \
	ro.telephony.call_ring.multiple=false \
	ro.telephony.call_ring.delay=3000 \
	ro.media.dec.jpeg.memcap=20000000 \
	dalvik.vm.lockprof.threshold=500 \
	ro.kernel.android.checkjni=0 \
	dalvik.vm.checkjni=false \
	dalvik.vm.dexopt-data-only=1 \
	ro.vold.umsdirtyratio=20 \
	net.dns1=8.8.8.8 \
	net.dns2=8.8.4.4

# we have enough storage space to hold precise GC data
PRODUCT_TAGS += dalvik.gc.type-precise

DEVICE_PACKAGE_OVERLAYS += device/motorola/sholest/overlay

# Permissions
PRODUCT_COPY_FILES += \
	frameworks/base/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
	frameworks/base/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
	frameworks/base/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
	frameworks/base/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
	frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/base/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
	frameworks/base/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
	frameworks/base/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/base/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
	frameworks/base/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
	packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:/system/etc/permissions/android.software.live_wallpaper.xml \


# MOTOROLA COMMON 
PRODUCT_PACKAGES += \
	mot_boot_mode \
    charge_only_mode 
# ICS sound
PRODUCT_PACKAGES += \
	libaudioutils audio.a2dp.default audio_policy.sholest \
	libaudiohw_legacy audio.primary.sholest \

# Lights 
PRODUCT_PACKAGES += \
	lights.sholest
# TO FIX for ICS
PRODUCT_PACKAGES += gralloc.default hwcomposer.default

# ICS Camera
PRODUCT_PACKAGES += Camera camera.sholest

# Wifi packages
PRODUCT_PACKAGES += iwmulticall hostap wlan_loader wlan_cu wpa_supplicant
PRODUCT_PACKAGES += libhostapdcli libCustomWifi libwpa_client libtiOsLib
PRODUCT_PACKAGES += tiwlan.ini dhcpcd.conf wpa_supplicant.conf hostapd.conf
PRODUCT_PACKAGES += tiap_loader tiap_cu ndc

# OMX stuff
PRODUCT_PACKAGES += dspexec libbridge libLCML libOMX_Core
PRODUCT_PACKAGES += libOMX.TI.AAC.encode libOMX.TI.AAC.decode libOMX.TI.AMR.decode
PRODUCT_PACKAGES += libOMX.TI.WBAMR.encode libOMX.TI.MP3.decode libOMX.TI.WBAMR.decode
PRODUCT_PACKAGES += libOMX.TI.WMA.decode libOMX.TI.Video.Decoder libOMX.TI.Video.encoder
#PRODUCT_PACKAGES += libOMX.TI.VPP
PRODUCT_PACKAGES += libskiahw libOMX.TI.JPEG.Encoder libOMX.TI.JPEG.decoder

# Sholest stuff
PRODUCT_PACKAGES += Usb 

PRODUCT_PACKAGES += e2fsck

# Bootmenu 
#PRODUCT_PACKAGES += bootmenu
#$(call inherit-product, device/motorola/sholest/bootmenu/bootmenu.mk)
# Publish that we support the live wallpaper feature.
PRODUCT_PACKAGES += LiveWallpapers LiveWallpapersPicker MagicSmokeWallpapers 
PRODUCT_PACKAGES += VisualizationWallpapers librs_jni

# Add DroidSSHd (dropbear) Management App - tpruvot/android_external_droidsshd @ github
#PRODUCT_PACKAGES += DroidSSHd dropbear dropbearkey sftp-server scp ssh

# CM9 apps
PRODUCT_PACKAGES += Trebuchet FileManager Torch

# Prebuilt boot.img
LOCAL_KERNEL := device/motorola/sholest/kernel
PRODUCT_COPY_FILES += \
	$(LOCAL_KERNEL):kernel


# Vendor blobs 
$(call inherit-product, device/motorola/sholest/sholest-blobs.mk)

# copy all files under the "prebuilt" directory to system
PRODUCT_COPY_FILES += $(shell \
    find device/motorola/sholest/prebuilt/ -type f \
    | sed -r 's/^(device\/motorola\/sholest\/prebuilt)(.*)$$/\1\2:\/system\2/' \
    | tr '\n' ' ')


######################################################################################################################################

$(call inherit-product, build/target/product/full_base.mk)

# Should be after the full_base include, which loads languages_full
PRODUCT_LOCALES += hdpi

PRODUCT_NAME := full_sholest
PRODUCT_DEVICE := sholest

