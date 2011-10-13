# Inherit AOSP device configuration for passion.
$(call inherit-product, device/motorola/sholest/sholest.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

# Include GSM stuff
#$(call inherit-product, vendor/cyanogen/products/gsm.mk)

# SIM Toolkit
PRODUCT_PACKAGES += \
    Stk

# Include the Flashlight/Torch
PRODUCT_PACKAGES += Torch

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_sholest
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := sholest
PRODUCT_MODEL := Milestone XT720
PRODUCT_MANUFACTURER := Motorola

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-MilestoneXT720
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7.1.0-MilestoneXT720-alpha-$(shell date +%m%d%Y) 
endif

PRODUCT_BUILD_PROP_OVERRIDES := BUILD_ID=R.U.R.1920 BUILD_DISPLAY_ID=R.U.R.1920 PRODUCT_NAME=sholest TARGET_DEVICE=sholest BUILD_FINGERPRINT=MOTO_RTEU/umts_sholes/umts_sholes/sholes:2.2.1/SHOLS_U2_05.26.3/296482885:user/release-keys PRODUCT_BRAND=MOTO_RTEU PRIVATE_BUILD_DESC="sholest-user 2.2.1 SHOLS_U2_05.26.3 296482885 release-keys" BUILD_NUMBER=296482885 BUILD_UTC_DATE=1295422848 TARGET_BUILD_TYPE=user BUILD_VERSION_TAGS=release-keys USER=android-build

# PRODUCT_SPECIFIC_DEFINES += TARGET_PRELINKER_MAP=$(TOP)/vendor/cyanogen/prelink-linux-arm-umts_sholes.map

# Enable Windows Media
WITH_WINDOWS_MEDIA := true

PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip

PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/sholest
