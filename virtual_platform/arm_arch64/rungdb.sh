#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)


export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-elf/bin/:$PATH"

# gdb
aarch64-none-elf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${shell_folder}/arm-trusted-firmware/build/a55/debug/bl1/bl1.elf" \
-ex "add-symbol-file ${shell_folder}/arm-trusted-firmware/build/a55/debug/bl2/bl2.elf" \
-ex "add-symbol-file ${shell_folder}/arm-trusted-firmware/build/a55/debug/bl31/bl31.elf" \
-ex "add-symbol-file ${shell_folder}/optee/optee_os/build/core/tee.elf" \
-ex "add-symbol-file ${shell_folder}/u-boot/u-boot" \
-q
 