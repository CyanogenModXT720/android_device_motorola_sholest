#!/system/bin/sh

BUSYBOX=/system/xbin/busybox

$BUSYBOX mkdir /system/persistent/orbootstrap/etc

#sh

$BUSYBOX rm /system/bin/sh
$BUSYBOX cp /system/persistent/orbootstrap/sh /system/bin/sh

#tag
$BUSYBOX touch /system/persistent/.persistent_sh

#permissions

$BUSYBOX chown 0:2000 /system/bin/sh
$BUSYBOX chmod 755 /system/bin/sh

$BUSYBOX chown -R 0:0 /system/persistent/orbootstrap/

$BUSYBOX chmod -R 644 /system/persistent/orbootstrap/res
$BUSYBOX chmod -R 644 /system/persistent/orbootstrap/menu
$BUSYBOX chmod -R 644 /system/persistent/orbootstrap/etc
$BUSYBOX chmod -R 755 /system/persistent/orbootstrap/sbin
$BUSYBOX chmod -R 755 /system/persistent/orbootstrap/utils

$BUSYBOX chmod -R 644 /system/persistent/orbootstrap/default.prop
$BUSYBOX chmod -R 755 /system/persistent/orbootstrap/init.rc

#symlinks
CWD="$PWD"
cd /system/persistent/orbootstrap/utils 
$BUSYBOX ln -s bootstrapbox cp
$BUSYBOX ln -s bootstrapbox mkdir
$BUSYBOX ln -s bootstrapbox mount
$BUSYBOX ln -s bootstrapbox rm
$BUSYBOX ln -s bootstrapbox rmdir
$BUSYBOX ln -s bootstrapbox umount
cd "$CWD"

#reboot (only if there is toolbox)

if [ -f /system/bin/toolbox ]; then

	$BUSYBOX rm /system/bin/reboot
	$BUSYBOX cp /system/persistent/orbootstrap/reboot /system/bin/reboot
	
	$BUSYBOX chown 0:2000 /system/bin/reboot
	$BUSYBOX chmod 755 /system/bin/reboot
	
fi

echo "Installation done."
