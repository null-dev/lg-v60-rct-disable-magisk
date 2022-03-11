_ui_print() {
  echo "lg-v60-rct-disable-magisk: $1" >> /cache/magisk.log
}

_abort() {
  echo "lg-v60-rct-disable-magisk ERROR: $1" >> /cache/magisk.log
  exit 1
}

if [ -f /data/adb/magisk/util_functions.sh ]; then
  . /data/adb/magisk/util_functions.sh
else
  _abort "Uninstallation failed, failed to locate magisk!"
fi

ui_print() {
  _ui_print "$1"
}

abort() {
  _abort "$1"
}

ui_print "Initializing environment..."

get_flags
find_boot_image

eval $BOOTSIGNER -verify < $BOOTIMAGE && BOOTSIGNED=true
$BOOTSIGNED && ui_print "- Boot image is signed with AVB 1.0"

OLDPWD="$PWD"
ui_print "Working directory: $PWD"
cd "$MODPATH" || abort "Failed to change working directory"

ui_print "New working directory: $PWD"

ui_print "Unpacking boot image ($BOOTIMAGE)..."
"$NVBASE/magisk/magiskboot" unpack "$BOOTIMAGE"

ui_print "Removing overlay scripts from ramdisk..."
"$NVBASE/magisk/magiskboot" cpio ramdisk.cpio \
"rm overlay.d/lg-disable-rctd.rc"

ui_print "Repacking boot image..."
"$NVBASE/magisk/magiskboot" repack "$BOOTIMAGE"

ui_print "Flashing new boot image..."
if ! flash_image new-boot.img "$BOOTIMAGE"; then
    abort "Failed to flash new boot image!"
fi

cd "$OLDPWD" || ui_print "Failed to return to old working directory"


# Don't modify anything after this
if [ -f $INFO ]; then
  while read LINE; do
    if [ "$(echo -n $LINE | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f $LINE~ $LINE
    else
      rm -f $LINE
      while true; do
        LINE=$(dirname $LINE)
        [ "$(ls -A $LINE 2>/dev/null)" ] && break 1 || rm -rf $LINE
      done
    fi
  done < $INFO
  rm -f $INFO
fi
