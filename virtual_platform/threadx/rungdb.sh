#!/bin/bash

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

demo_dir=${shell_folder}/threadx_platform/platform/thomas_m3

# gdb
arm-none-eabi-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${demo_dir}/build/thomas_m3.elf" \
-q
