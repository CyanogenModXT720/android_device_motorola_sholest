# This script is included in squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
rm -f $REPACK/ota/system/app/CMUpdateNotify.apk
rm -f $REPACK/ota/system/app/RomManager.apk
rm -f $REPACK/ota/system/xbin/irssi

# prebuilt boot, devtree, logo & updater-script
#cp -f $ANDROID_BUILD_TOP/vendor/motorola/sholest/proprietary/boot.img $REPACK/ota/
cp -f $ANDROID_BUILD_TOP/device/motorola/sholest/updater-script $REPACK/ota/META-INF/com/google/android/updater-script

# Save build manifest into update
repo manifest -r -o $REPACK/ota/system/repo-default.xml
gzip $REPACK/ota/system/repo-default.xml

