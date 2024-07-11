#!/bin/bash

export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-elf/bin/:$PATH"

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

demo_elf=${shell_folder}/baremetal/qemu-bm-thomas-a53/output/target.elf

# gdb
aarch64-none-elf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${demo_elf}" \
-q 
