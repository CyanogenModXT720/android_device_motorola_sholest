# This script is included in squisher
# It is the final build step (after OTA package)

# prebuilt boot, devtree, logo & updater-script
#cp -f $ANDROID_BUILD_TOP/vendor/motorola/sholest/proprietary/boot.img $REPACK/ota/

MODVERSION=`sed -n -e'/ro\.modversion/s/^.*CyanogenMod-/CyanogenMod-/p' $REPACK/ota/system/build.prop`
sed -e "s/MODVERSION/$MODVERSION/g" $ANDROID_BUILD_TOP/device/motorola/sholest/updater-script > $REPACK/ota/META-INF/com/google/android/updater-script

