#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

# Cortex-M
#export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin/:$PATH"

# Cortex-A arch32
# 180 server
#export PATH="/root/workspace/.toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin/:$PATH"
#export PATH="/root/workspace/.toolchains/cmake-3.20.5-linux-x86_64/bin/:$PATH"

export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin/:$PATH"
export CROSS_COMPILE=arm-none-eabi-

# change to SMP branch kernel
#cd "${shell_folder}/FreeRTOS/FreeRTOS/Source" || exit
#git checkout origin/smp

# which demo to compile
examples_dir=${shell_folder}/FreeRTOS/FreeRTOS/Demo/THOMAS_A15_QEMU


# output
elf=${shell_folder}/FreeRTOS/FreeRTOS/Demo/THOMAS_A15_QEMU/build/thomas_a15.elf

# build makefile
cd "${examples_dir}" || exit
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug

# build
cd "${examples_dir}" || exit
make -C build

# dump
cd "${shell_folder}" || exit
rm -f freertos.asm
arm-none-eabi-objdump -xD ${elf} > freertos.asm
