#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

# which demo to run
demo_dir=${shell_folder}/FreeRTOS/FreeRTOS/Demo/THOMAS_A15_QEMU

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine thomas-a15"
qemu_option+=" -kernel ${demo_dir}/build/thomas_a15.elf"
qemu_option+=" -serial stdio"
qemu_option+=" -smp 2"

# Change to develop qemu
#gdb --args qemu/build/arm-softmmu/qemu-system-arm -d in_asm,out_asm,cpu ${qemu_option}

# run qemu
qemu/build/qemu-system-arm ${qemu_option}

