#!/system/bin/sh
#turn on logcat during boot
   /system/xbin/busybox echo "msc_adb" > /dev/usb_device_mode
   /system/xbin/busybox touch /tmp/usbd-state
   /system/xbin/busybox chown system.system /tmp/usbd-state
   /system/xbin/busybox echo -n "usb_mode_ngp_adb" > /tmp/usbd-state
   /system/xbin/mount -o remount,rw rootfs /
   /system/xbin/rmdir /config
   /system/xbin/rmdir /sdcard
   /system/xbin/cp -fr /etc/rootfs/* /

#   echo "-16" > /proc/$$/oom_adj

   /system/xbin/umount /dev/cpuctl
   /system/xbin/umount /sqlite_stmt_journals
   /system/xbin/umount /dev/pts

   exec /system/bin/2nd-init
