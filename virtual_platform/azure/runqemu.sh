#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

# which demo to compile
demo_dir=${shell_folder}/azure/platform/thomas_m3

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine thomas-m3"
qemu_option+=" -kernel ${demo_dir}/build/thomas_m3.elf"
qemu_option+=" -serial stdio"

# run qemu
qemu/build/qemu-system-arm ${qemu_option}
