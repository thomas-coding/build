#!/bin/bash

# Shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

# boot source
boot_from_sd=1

# support display
display_enable=0

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine thomas-tiger"
#qemu_option+=" -kernel ${shell_folder}/baremetal/a55/output/a55.elf"
qemu_option+=" -kernel ${shell_folder}/out/x5/intermediate/atf/horizon/release/bl1/bl1.elf"
qemu_option+=" -device loader,file=${shell_folder}/out/x5/fip.bin,addr=0x1ff00000"
qemu_option+=" -device loader,file=${shell_folder}/out/x5/images/x5.itb,addr=0x82000000"
qemu_option+=" -device loader,file=${shell_folder}/out/x5/images/x5.dtb,addr=0x81000000"

#qemu_option+=" -drive if=sd,file=${shell_folder}/sd.disk,format=raw"
#qemu_option+=" -smp 2"

qemu_option+=" -nographic"
qemu_option+=" -d guest_errors"


# Change to develop qemu
#gdb --args qemu/build/arm-softmmu/qemu-system-arm -d in_asm,out_asm,cpu ${qemu_option}

qemu/build/aarch64-softmmu/qemu-system-aarch64 ${qemu_option}
