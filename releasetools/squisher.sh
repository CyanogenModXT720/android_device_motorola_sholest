# This script is included in squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
rm -f $REPACK/ota/system/app/VideoEditor.apk
rm -f $REPACK/ota/system/app/RomManager.apk
rm -f $REPACK/ota/system/media/video/*.480p.mp4
rm -f $REPACK/ota/system/etc/init.d/04modules

# Opensource init binary
cp -f $DEVICE_OUT/root/init $REPACK/ota/system/bootmenu/2nd-init/init

# Use a prebuilt adbd configured for root access instead of normal one, for dev purpose
cp -f $REPACK/ota/system/bootmenu/binary/adbd $REPACK/ota/system/bin/adbd
#cp -f $DEVICE_OUT/root/sbin/adbd $REPACK/ota/system/bin/adbd

cp -f $DEVICE_TOP/bootmenu/binary/2nd-init $REPACK/ota/system/bootmenu/binary/2nd-init

# use the static busybox as bootmenu shell, and some static utilities
cp -f $DEVICE_OUT/utilities/busybox $REPACK/ota/system/bootmenu/binary/busybox
cp -f $DEVICE_OUT/utilities/lsof $REPACK/ota/system/bootmenu/binary/lsof

cp -f $REPACK/ota/system/lib/hw/audio.a2dp.default.so $REPACK/ota/system/lib/liba2dp.so

# prebuilt boot, devtree, logo & updater-script

MODVERSION=`sed -n -e'/ro\.modversion/s/^.*CyanogenMod-/CyanogenMod-/p' $REPACK/ota/system/build.prop`
sed -e "s/MODVERSION/$MODVERSION/g" $ANDROID_BUILD_TOP/device/motorola/sholest/updater-script > $REPACK/ota/META-INF/com/google/android/updater-script

# Save build manifest into update

