#!/bin/bash

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"

# GDB port
#port=2331
port=3333

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

demo_dir=${shell_folder}/bear/baremetal
demo_elf=${demo_dir}/build/bear.elf

pc_value=0x202007c0

# gdb
arm-none-eabi-gdb \
-ex 'target extended-remote localhost:3333' \
-ex "load ${demo_elf}" \
-ex "add-symbol-file ${demo_elf}" \
-ex "si" \
-ex "monitor reset halt" \
-ex "si" \
-ex "set \$pc=${pc_value}" \
-q
