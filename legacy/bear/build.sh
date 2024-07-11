#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)
export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"

baremetal_dir=${shell_folder}/bear/baremetal
mbedtls_dir=${shell_folder}/mbedtls

# build mbedtls
cd "${mbedtls_dir}" || exit
rm -rf build
cmake -B build -DENABLE_TESTING=Off -DENABLE_PROGRAMS=Off -DTEST_CPP=Off -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=${baremetal_dir}/cmake/cortex_m33.cmake
cmake --build ./build

# build baremetal
cd "${baremetal_dir}" || exit
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=cmake/cortex_m33.cmake
cmake --build ./build


