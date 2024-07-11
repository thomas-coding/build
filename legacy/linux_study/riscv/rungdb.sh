#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)


export PATH="/home/cn1396/workspace/code/riscv64_test/riscv/bin:$PATH"

opensbi_elf=${shell_folder}/opensbi/build/platform/generic/firmware/fw_payload.elf
uboot_elf=${shell_folder}/u-boot/u-boot

#cd ${bm_dir}
# gdb
riscv64-unknown-linux-gnu-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${opensbi_elf}" \
-ex "add-symbol-file ${uboot_elf}" \
-q
 