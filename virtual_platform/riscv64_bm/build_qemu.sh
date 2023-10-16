#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

qemu_dir=${shell_folder}/qemu
cd "${qemu_dir}" || exit
#./configure --target-list=aarch64-softmmu,arm-softmmu,riscv32-softmmu,riscv64-softmmu --enable-debug --disable-werror
#./configure --target-list=arm-softmmu --enable-debug
make -j6
