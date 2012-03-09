######## BootMenu Script Env
######## common variables for scripts

export PATH=/sbin:/system/xbin:/system/bin

PART_SYSTEM=/dev/block/mtdblock7
PART_CACHE=/dev/block/mtdblock8
PART_DATA=/dev/block/mtdblock9
PART_PDS=/dev/block/mtdblock10

FS_SYSTEM=yaffs2
FS_CACHE=yaffs2
FS_DATA=yaffs2

FS_PDS=yaffs2

BM_ROOTDIR=/system/bootmenu

BOARD_UMS_LUNFILE=/sys/devices/platform/usb_mass_storage/lun0/file

