# Inherit AOSP device configuration.
$(call inherit-product, device/motorola/sholest/sholest.mk)

# Inherit common GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_sholest
PRODUCT_BRAND := MOTO
PRODUCT_MODEL := XT720
PRODUCT_DEVICE := sholest
PRODUCT_MANUFACTURER := Motorola

# Release name and versioning
PRODUCT_RELEASE_NAME := MilestoneXT720
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

PRODUCT_BUILD_PROP_OVERRIDES := \
PRODUCT_NAME=sholest \
TARGET_DEVICE=sholest \
PRODUCT_BRAND=MOTO \
USER=CyanogenModXT720

PRODUCT_COPY_FILES += \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip

PRODUCT_PACKAGE_OVERLAYS += \
    vendor/cyanogen/overlay/sholest

# Add the Torch app
PRODUCT_PACKAGES += \
    Torch

PRODUCT_BUILD_PROP_OVERRIDES += \
PRIVATE_BUILD_DESC="str-user 2.3.7 STR_U2_03.20.1 1281000449 release-keys" \
BUILD_FINGERPRINT=Motorola/STR_RTRU/sholest/sholes:2.3.7/STR_U2_03.20.1/1281000449:user/release-keys
