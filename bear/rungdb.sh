#!/bin/bash

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

demo_dir=${shell_folder}/bear/baremetal
demo_elf=${demo_dir}/build/bear.elf


# gdb
arm-none-eabi-gdb \
-ex 'target remote localhost:2331' \
-ex "load ${demo_elf}" \
-ex "add-symbol-file ${demo_elf}" \
-q
