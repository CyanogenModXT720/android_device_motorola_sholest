# This script is included in squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
rm -f $REPACK/ota/system/app/CMStats.apk
rm -f $REPACK/ota/system/app/CMStats.odex
rm -f $REPACK/ota/system/app/CMUpdateNotify.apk
rm -f $REPACK/ota/system/app/CMUpdateNotify.odex
rm -f $REPACK/ota/system/app/RomManager.apk
rm -f $REPACK/ota/system/app/RomManager.odex
rm -f $REPACK/ota/system/xbin/irssi
    
# Location Proxy injection
printf "Injecting smali..."
(
SMALID=$OUT/smali.d
rm -rf $SMALID
mkdir -p $SMALID
cd $SMALID
unzip $QUIET $REPACK/ota/system/framework/framework.jar "classes.dex"
java -Xmx512m \
	-jar $ANDROID_BUILD_TOP/vendor/cyanogen/tools/baksmali.jar classes.dex -o framework
cp -fr $ANDROID_BUILD_TOP/device/motorola/sholest/smali/framework/* framework
java -Xmx512m \
	-jar $ANDROID_BUILD_TOP/vendor/cyanogen/tools/smali.jar framework -o classes.dex
zip $QUIET $REPACK/ota/system/framework/framework.jar "classes.dex"
rm -f classes.dex
unzip $QUIET $REPACK/ota/system/framework/services.jar "classes.dex"
java -Xmx512m \
	-jar $ANDROID_BUILD_TOP/vendor/cyanogen/tools/baksmali.jar classes.dex -o services
cp -fr $ANDROID_BUILD_TOP/device/motorola/sholest/smali/services/* services
sed -i '/Location Proxy Service/,/I/ c\
    const-string v9, "Starting Location Proxy."\
\
    invoke-static {v5, v9}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I\
\
    const-string v5, "locationproxy"\
\
    new-instance v9, Lcom/android/server/LocationProxyService;\
\
    invoke-direct {v9, v6}, Lcom/android/server/LocationProxyService;-><init>(Landroid/content/Context;)V\
\
    invoke-static {v5, v9}, Landroid/os/ServiceManager;->addService(Ljava/lang/String;Landroid/os/IBinder;)V' services/com/android/server/ServerThread.smali
java -Xmx512m \
	-jar $ANDROID_BUILD_TOP/vendor/cyanogen/tools/smali.jar services -o classes.dex
zip $QUIET $REPACK/ota/system/framework/services.jar "classes.dex"
rm -rf $SMALID
)
echo

# prebuilt boot, devtree, logo & updater-script
#cp -f $ANDROID_BUILD_TOP/vendor/motorola/sholest/proprietary/boot.img $REPACK/ota/
cp -f $ANDROID_BUILD_TOP/device/motorola/sholest/updater-script $REPACK/ota/META-INF/com/google/android/updater-script

# Save build manifest into update
repo manifest -r -o $REPACK/ota/system/repo-default.xml
gzip $REPACK/ota/system/repo-default.xml

