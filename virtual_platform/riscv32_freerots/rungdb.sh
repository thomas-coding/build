#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/root/.toolchain/riscv32_nofloat/bin:$PATH"

elf_dir=FreeRTOS/FreeRTOS/Demo/THOMAS_RISCV32_QEMU/build

cd ${elf_dir}
# gdb
#riscv64-unknown-linux-gnu-gdb \
riscv32-unknown-elf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${shell_folder}/${elf_dir}/thomas_riscv32.elf" \
-q
 