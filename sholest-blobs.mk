# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,BOARD
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := \
    device/motorola/sholest/proprietary/lib/libgps.so:obj/lib/libgps.so \
    device/motorola/sholest/proprietary/lib/libcamera.so:obj/lib/libcamera.so \
    device/motorola/sholest/proprietary/lib/libaudio.so:obj/lib/libaudio.so \
    device/motorola/sholest/proprietary/lib/libril-moto-umts-1.so:obj/lib/libril-moto-umts-1.so \
    device/motorola/sholest/proprietary/lib/hw/gralloc.omap3.so:obj/lib/hw/gralloc.omap3.so


#KEYBOARD
PRODUCT_COPY_FILES := \
    prebuilt/usr/idc/internal.idc:system/usr/idc/lm3530_led.idc \
    prebuilt/usr/idc/internal.idc:system/usr/idc/accelerometer.idc \
    prebuilt/usr/idc/internal.idc:system/usr/idc/compass.idc \
    prebuilt/usr/idc/internal.idc:system/usr/idc/light-prox.idc \
    prebuilt/usr/idc/internal.idc:system/usr/idc/proximity.idc \
    prebuilt/usr/idc/sholes-keypad.idc:system/usr/idc/sholes-keypad.idc \
    prebuilt/usr/idc/cpcap-key.idc:system/usr/idc/cpcap-key.idc \
    prebuilt/usr/idc/qtouch-touchscreen.idc:system/usr/idc/qtouch-touchscreen.idc \
    prebuilt/usr/qwerty.kl:system/usr/keylayout/qwerty.kl \
    prebuilt/usr/qwerty.kl:system/usr/keylayout/qtouch-touchscreen.kl \
    prebuilt/usr/keypad.kl:system/usr/keylayout/sholes-keypad.kl \
    prebuilt/usr/keypad.kl:system/usr/keylayout/umts_jordan-keypad.kl \
    prebuilt/usr/cpcap-key.kl:system/usr/keylayout/cpcap-key.kl \
    prebuilt/usr/keychars/cpcap-key.kcm:system/usr/keychars/cpcap-key.kcm

# All the blobs necessary 
# copy all files under the "proprietary" directory to system
PRODUCT_COPY_FILES += $(shell \
    find device/motorola/sholest/proprietary/ -type f \
    | sed -r 's/^(device\/motorola\/sholest\/proprietary)(.*)$$/\1\2:\/system\2/' \
    | tr '\n' ' ')
