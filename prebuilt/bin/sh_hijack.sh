#!/system/bin/sh
   /system/xbin/mount -o remount,rw rootfs /
   /system/xbin/rmdir /config
   /system/xbin/rmdir /sdcard
   /system/xbin/rm -f /sbin/charge_only_mode
   /system/xbin/rm -f /*.rc
   /system/xbin/rm -f /*.sh
   /system/xbin/cp -fr /etc/rootfs/* /
   /system/xbin/chmod 750 /sbin/*
   /system/xbin/chmod 750 /init
   /system/xbin/ln -s /init /sbin/ueventd
   /system/xbin/busybox touch /tmp/usbd-state
   /system/xbin/busybox chmod 777 /tmp/usbd-state
   /system/xbin/busybox echo "disconnected"> /tmp/usbd-state

#   echo "msc_adb" > /dev/usb_device_mode
   echo "usb_mode_msc_adb" > /tmp/usbd_current_state

   exec /system/bin/2nd-init
