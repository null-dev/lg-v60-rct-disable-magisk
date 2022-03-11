get_flags
find_boot_image

ui_print "Unpacking boot image ($BOOTIMAGE)..."
"$NVBASE/magisk/magiskboot" unpack "$BOOTIMAGE"

ui_print "Adding overlay scripts to ramdisk..."
"$NVBASE/magisk/magiskboot" cpio ramdisk.cpio \
"mkdir 0700 overlay.d" \
"add 0700 overlay.d/lg-disable-rctd.rc $MODPATH/ramdisk/init.rc"

ui_print "Repacking boot image..."
"$NVBASE/magisk/magiskboot" repack "$BOOTIMAGE"

ui_print "Flashing new boot image..."
if ! flash_image new-boot.img "$BOOTIMAGE"; then
    abort "Failed to flash new boot image!"
fi
