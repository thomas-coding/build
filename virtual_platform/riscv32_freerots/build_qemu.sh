#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

qemu_dir=${shell_folder}/qemu
cd "${qemu_dir}" || exit
./configure --target-list=riscv32-softmmu --enable-debug --disable-werror
#./configure --target-list=arm-softmmu --enable-debug
make -j6
