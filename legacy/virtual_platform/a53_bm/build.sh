#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-elf/bin/:$PATH"


#cd ${shell_folder}/baremetal/qemu-bm-thomas-a53/
#./build.sh c
#./build.sh a

cd "${shell_folder}/baremetal/qemu-bm-thomas-a53/" || exit
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=cmake/cortex_a53.cmake
cmake --build ./build
