#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

git clone https://github.com/thomas-coding/qemu.git --recurse-submodules

cd ${shell_folder}/qemu
./configure --target-list=aarch64-softmmu --enable-debug
make -j8 || exit