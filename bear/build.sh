#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)
export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"



platform_dir=${shell_folder}/bear/baremetal

# build
cd "${platform_dir}" || exit
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=cmake/cortex_m33.cmake
cmake --build ./build
