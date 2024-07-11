#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin/:$PATH"
export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin/:$PATH"
export CROSS_COMPILE=arm-none-eabi-

export PICO_SDK_PATH=/home/cn1396/workspace/code/pi_pico/pico-sdk

# which demo to compile
source_dir=${shell_folder}/picoprobe

# build makefile
cd "${source_dir}" || exit
rm -rf build
cmake -B build

# build demo
cd "${source_dir}" || exit
make -C build
