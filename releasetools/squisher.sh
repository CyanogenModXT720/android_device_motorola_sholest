# This script is included in squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
rm -f $REPACK/ota/system/app/CMUpdateNotify.apk
rm -f $REPACK/ota/system/app/RomManager.apk
rm -f $REPACK/ota/system/xbin/irssi

# prebuilt boot, devtree, logo & updater-script

MODVERSION=`sed -n -e'/ro\.modversion/s/^.*CyanogenMod-/CyanogenMod-/p' $REPACK/ota/system/build.prop`
sed -e "s/MODVERSION/$MODVERSION/g" $ANDROID_BUILD_TOP/device/motorola/sholest/updater-script > $REPACK/ota/META-INF/com/google/android/updater-script

# Save build manifest into update

