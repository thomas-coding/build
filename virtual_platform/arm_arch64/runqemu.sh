#!/bin/bash

# Shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/root/workspace/software/qemu/qemu-6.0.0/build/:$PATH"

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine thomas-a55"
qemu_option+=" -kernel ${shell_folder}/arm-trusted-firmware/build/a55/release/bl1/bl1.elf"
qemu_option+=" -device loader,file=${shell_folder}/arm-trusted-firmware/build/a55/release/fip.bin,addr=0x21000000"
qemu_option+=" -device loader,file=${shell_folder}/linux/arch/arm64/boot/Image,addr=0x32000000"
qemu_option+=" -device loader,file=${shell_folder}/linux/arch/arm64/boot/dts/virtual_platform/a55.dtb,addr=0x36000000"
qemu_option+=" -d guest_errors"
qemu_option+=" -nographic"

# Change to develop qemu
#gdb --args qemu/build/arm-softmmu/qemu-system-arm -d in_asm,out_asm,cpu ${qemu_option}

qemu/build/aarch64-softmmu/qemu-system-aarch64 ${qemu_option}
