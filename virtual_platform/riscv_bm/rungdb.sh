#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)


#export PATH="/opt/riscv/bin:$PATH"
export PATH="/opt/riscv32/bin:$PATH"
export PATH="/home/cn1396/workspace/.toolchains/riscv/riscv32/bin:$PATH"
export PATH="/home/cn1396/.toolchain/riscv/riscv32/bin:$PATH"

bm_dir=baremetal/baremetal-riscv32
cd ${bm_dir}
# gdb
#riscv64-unknown-linux-gnu-gdb \
riscv32-unknown-elf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${shell_folder}/${bm_dir}/output/target.elf" \
-q
 