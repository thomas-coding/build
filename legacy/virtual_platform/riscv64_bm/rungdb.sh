#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)


#export PATH="/opt/riscv/bin:$PATH"
export PATH="/home/cn1396/.toolchain/riscv/riscv64-elf-ubuntu-20.04-gcc-nightly-2023.10.12-nightly/bin:$PATH"

bm_dir=baremetal/qemu-bm-thomas-riscv64
cd ${bm_dir}
# gdb
#riscv64-unknown-linux-gnu-gdb \
riscv64-unknown-elf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${shell_folder}/${bm_dir}/output/target.elf" \
-q
 