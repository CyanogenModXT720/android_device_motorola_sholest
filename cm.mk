## Specify phone tech before including full_phone
$(call inherit-product, vendor/cm/config/gsm.mk)

# Release name
PRODUCT_RELEASE_NAME := Milestone XT720

# Inherit some common CM stuff.
$(call inherit-product, vendor/cm/config/common_full_phone.mk)

# Inherit device configuration
$(call inherit-product, device/motorola/sholest/full_sholest.mk)

## Device identifier. This must come after all inclusions
PRODUCT_NAME := cm_sholest
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := sholest
PRODUCT_MODEL := Milestone XT720
PRODUCT_MANUFACTURER := Motorola

#Set build fingerprint / ID / Product Name ect.


