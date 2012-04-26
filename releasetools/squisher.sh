# This script is included in squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
DEVICE_OUT=$ANDROID_BUILD_TOP/out/target/product/sholest
rm -f $REPACK/ota/system/app/CMUpdateNotify.apk
rm -f $REPACK/ota/system/app/RomManager.apk
rm -f $REPACK/ota/system/xbin/irssi

# prebuilt boot, devtree, logo & updater-script
#cp -f $ANDROID_BUILD_TOP/vendor/motorola/sholest/proprietary/boot.img $REPACK/ota/

#copy init and init.rc from aosp
cp -f $DEVICE_OUT/root/init $REPACK/ota/system/etc/rootfs/init
cp -f $DEVICE_OUT/root/init.rc $REPACK/ota/system/etc/rootfs/init.rc


MODVERSION=`sed -n -e'/ro\.modversion/s/^.*CyanogenMod-/CyanogenMod-/p' $REPACK/ota/system/build.prop`
sed -e "s/MODVERSION/$MODVERSION/g" $ANDROID_BUILD_TOP/device/motorola/sholest/updater-script > $REPACK/ota/META-INF/com/google/android/updater-script

# Save build manifest into update

