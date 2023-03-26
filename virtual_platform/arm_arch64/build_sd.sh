#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

#image_dir=${shell_folder}/out/images
sleep 1

echo "shell_folder:${shell_folder}"

# Create 32M sd card
rm -f ${shell_folder}/sd.disk
dd if=/dev/zero of=${shell_folder}/sd.disk bs=1M count=32

# Burn fip.bin to sd card, offset 20K
dd if=${shell_folder}/arm-trusted-firmware/build/a55/release/fip.bin of=sd.disk conv=fsync,notrunc bs=512 seek=40
sync
