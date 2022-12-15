#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

# which demo to run
demo_elf=${shell_folder}/baremetal/qemu-bm-thomas-a53/output/target.elf

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine thomas-a53"
qemu_option+=" -kernel ${demo_elf}"
qemu_option+=" -nographic"
#qemu_option+=" -serial stdio"
#qemu_option+=" -smp 2"

# Change to develop qemu
#gdb --args qemu/build/arm-softmmu/qemu-system-arm -d in_asm,out_asm,cpu ${qemu_option}

# run qemu
qemu/build/aarch64-softmmu/qemu-system-aarch64 ${qemu_option}

