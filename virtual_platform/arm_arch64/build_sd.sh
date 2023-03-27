#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

rawblkload=1

echo "shell_folder:${shell_folder}"

# Create 32M sd card
rm -f ${shell_folder}/sd.disk
dd if=/dev/zero of=${shell_folder}/sd.disk bs=1M count=256

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
fi

