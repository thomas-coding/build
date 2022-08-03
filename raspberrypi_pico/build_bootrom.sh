#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

# only this gcc version can fit size to ROM
#export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin/:$PATH"
export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-9-2020-q2-update/bin/:$PATH"
export CROSS_COMPILE=arm-none-eabi-

export PICO_SDK_PATH=/home/cn1396/workspace/code/pi_pico/pico-sdk

# bootrom dir
source_dir=${shell_folder}/pico-bootrom
elf=${shell_folder}/pico-bootrom/build/bootrom.elf
name=bootrom

# build makefile
cd "${source_dir}" || exit
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug

# build
cd "${source_dir}" || exit
make -C build

cd "${shell_folder}" || exit
rm -f ${name}.asm
arm-none-eabi-objdump -xD ${elf} > ${name}.asm
