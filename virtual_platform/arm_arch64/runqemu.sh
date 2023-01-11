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
qemu_option+=" -kernel ${shell_folder}/arm-trusted-firmware/build/a55/debug/bl1/bl1.elf"
#qemu_option+=" -serial stdio"
qemu_option+=" -device loader,file=${shell_folder}/arm-trusted-firmware/build/a55/debug/fip.bin,addr=0x21000000"
#qemu_option+=" -device loader,file=${shell_folder}/arm-trusted-firmware/build/a15/debug/bl32.bin,addr=0x00200000"
#qemu_option+=" -device loader,file=${shell_folder}/u-boot/u-boot.bin,addr=0x20000000"
#qemu_option+=" -device loader,file=${shell_folder}/linux/arch/arm/boot/uImage,addr=0x25000000"
#qemu_option+=" -device loader,file=${shell_folder}/linux/arch/arm/boot/dts/a15.dtb,addr=0x26000000"
qemu_option+=" -d guest_errors"
qemu_option+=" -nographic"
# Run qemu
#qemu/build/arm-softmmu/qemu-system-arm ${qemu_option}

# Change to develop qemu
#gdb --args qemu/build/arm-softmmu/qemu-system-arm -d in_asm,out_asm,cpu ${qemu_option}

qemu/build/aarch64-softmmu/qemu-system-aarch64 ${qemu_option}
