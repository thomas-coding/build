#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin/:$PATH"
export PICO_SDK_PATH=${shell_folder}/pico-sdk
export FREERTOS_KERNEL_PATH=${shell_folder}/FreeRTOS/FreeRTOS/Source

# change to SMP branch kernel
cd "${shell_folder}/FreeRTOS/FreeRTOS/Source" || exit
git checkout origin/smp

# which demo to compile
examples_dir=${shell_folder}/FreeRTOS/FreeRTOS/Demo/CORTEX_M0+_RP2040
if [[ ! -d ${examples_dir} ]]; then
    cp -rf ${shell_folder}/FreeRTOS/FreeRTOS/Demo/ThirdParty/Community-Supported/CORTEX_M0+_RP2040 \
        ${shell_folder}/FreeRTOS/FreeRTOS/Demo/CORTEX_M0+_RP2040
fi

# output
elf=${shell_folder}/FreeRTOS/FreeRTOS/Demo/CORTEX_M0+_RP2040/build/OnDualCore/on_dual_core.elf

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
