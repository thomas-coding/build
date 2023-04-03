#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

rawblkload=0

sd_name=sd.disk

echo "shell_folder:${shell_folder}"

# Create 32M sd card
rm -f ${shell_folder}/${sd_name}
dd if=/dev/zero of=${shell_folder}/sd.disk bs=1M count=1024

# Burn fip.bin to sd card, offset 20K
dd if=${shell_folder}/arm-trusted-firmware/build/a55/release/fip.bin of=sd.disk conv=fsync,notrunc bs=512 seek=40
sync

# rawblkload, put dtb and Image to SD card, uboot through mmc read, read it from sd card to ddr
if [[ ${rawblkload} = 1 ]]; then
    # Burn a55.dtb to sd card, offset 16MB
    # Refer: u-boot/include/configs/a55.h
    dd if=${shell_folder}/linux/arch/arm64/boot/dts/virtual_platform/a55.dtb of=sd.disk conv=fsync,notrunc bs=512 seek=32768
    sync

    # Burn Image to sd card, offset 18MB
    # Refer: u-boot/include/configs/a55.h
    dd if=${shell_folder}/linux/arch/arm64/boot/Image of=sd.disk conv=fsync,notrunc bs=512 seek=36864
    sync

    exit
fi

# emulate virtual block device
loopdev=`sudo losetup -f`
echo "loop dev: ${loopdev}"

sudo losetup ${loopdev} ${sd_name}
#losetup -a

#
# p1: offset 50M, size 450M image
# 102400 = 102400 * 512 = 50M
# p2: offset 500M, size 300M rootfs
# p3: offset 800M, size 200M pstore

sudo fdisk ${loopdev} <<EOF1
n
p
1
102400
+450M
n
p
2
1024000
+300M
n
p
3
1638400

t
1
c
p
w

EOF1

# probe partition, get /dev/loop100p1 and /dev/loop100p2
sudo partprobe ${loopdev}

# make file system
sudo mkfs.vfat -I ${loopdev}p1
sudo mkfs.ext4 ${loopdev}p2 -F

# copy image to sd
echo "----- copy kernel image and dtb"
sudo rm -rf ${shell_folder}/tmp
mkdir ${shell_folder}/tmp
sudo mount -t vfat ${loopdev}p1 ${shell_folder}/tmp
sudo cp -f -r ${shell_folder}/linux/arch/arm64/boot/dts/virtual_platform/a55.dtb ${shell_folder}/tmp
sudo cp -f -r ${shell_folder}/linux/arch/arm64/boot/Image ${shell_folder}/tmp
sync
sleep 1
sudo umount ${shell_folder}/tmp
echo "----- install image done"

# copy rootfs
echo "----- install rootfs"
sudo mount -t ext4 ${loopdev}p2 ${shell_folder}/tmp
cd ${shell_folder}/tmp
sudo cpio -idm < ${shell_folder}/out/images/rootfs.cpio
sync
sleep 1
cd ..
sudo umount ${shell_folder}/tmp
echo "----- install rootfs done"

# remove block device
sudo losetup -d ${loopdev}
