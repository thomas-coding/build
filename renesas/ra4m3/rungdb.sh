#!/bin/bash

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.10/bin:$PATH"

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

demo_dir=${shell_folder}/peaks
demo_elf=${demo_dir}/build/rm_freertos_port/ra4m3_ek/gcc/build_rm_freertos_port_typical_debug/build_rm_freertos_port_typical_debug.elf


# gdb
arm-none-eabi-gdb \
-ex 'target remote localhost:3333' \
-ex "load ${demo_elf}" \
-ex "add-symbol-file ${demo_elf}" \
-q
