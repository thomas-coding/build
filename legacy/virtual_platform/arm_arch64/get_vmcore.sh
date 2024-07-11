#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

rawblkload=0

sd_name=sd.disk

# emulate virtual block device
loopdev=`sudo losetup -f`
echo "loop dev: ${loopdev}"

sudo losetup ${loopdev} ${sd_name}
#losetup -a

# probe partition, get /dev/loop100p1 and /dev/loop100p2
sudo partprobe ${loopdev}

# get vmcore from sd card
echo "----- get vmcore from sd card "
sudo rm -rf ${shell_folder}/tmp
mkdir ${shell_folder}/tmp
sudo mount -t vfat ${loopdev}p1 ${shell_folder}/tmp
sudo rm -f -r ${shell_folder}/vmcore
sudo cp -f -r ${shell_folder}/tmp/vmcore ${shell_folder}/
sync
sleep 1
sudo umount ${shell_folder}/tmp
echo "----- get vmcore from sd card done"


# remove block device
sudo losetup -d ${loopdev}
