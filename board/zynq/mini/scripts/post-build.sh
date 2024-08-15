#!/bin/sh

# genimage will need to find the extlinux.conf
# in the binaries directory

linux_image()
{
	if grep -Eq "^BR2_LINUX_KERNEL_UIMAGE=y$" ${BR2_CONFIG}; then
		echo "uImage"
	elif grep -Eq "^BR2_LINUX_KERNEL_IMAGE=y$" ${BR2_CONFIG}; then
		echo "Image"
	elif grep -Eq "^BR2_LINUX_KERNEL_IMAGEGZ=y$" ${BR2_CONFIG}; then
		echo "Image.gz"
	else
		echo "zImage"
	fi
}

PARTUUID="$($HOST_DIR/bin/uuidgen)"

install -d "$TARGET_DIR/boot"

sed -e "s/%LINUXIMAGE%/$(linux_image)/g" \
	-e "s/%PARTUUID%/$PARTUUID/g" \
	"board/zynq/mini/config/extlinux.conf" > "${BINARIES_DIR}/extlinux.conf"

sed "s/%PARTUUID%/$PARTUUID/g" "board/zynq/mini/config/genimage.cfg" > "$BINARIES_DIR/genimage.cfg"

if [ ! -n "$(grep -r "/dev/mmcblk0p1" $TARGET_DIR/etc/fstab)" ]; then
	echo "/dev/mmcblk0p1	/boot	vfat	defaults 0 0" >> $TARGET_DIR/etc/fstab
fi
