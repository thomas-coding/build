#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"
export CROSS_COMPILE=arm-none-eabi-

cd ${shell_folder}/threadx
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=cmake/cortex_m3.cmake -GNinja .
cmake --build ./build

# which demo to compile
demo_dir=${shell_folder}/threadx/project/thomas_m3

# build
cd "${demo_dir}" || exit
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build ./build
