#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

#export PATH="/root/.toolchain/riscv/bin:$PATH"
#export PATH="/root/.toolchain/riscv32/bin:$PATH"
export PATH="/root/.toolchain/riscv32_nofloat/bin:$PATH"

export CROSS_COMPILE=riscv32-unknown-elf-

# change to SMP branch kernel
#cd "${shell_folder}/FreeRTOS/FreeRTOS/Source" || exit
#git checkout origin/smp

# which demo to compile
examples_dir=${shell_folder}/FreeRTOS/FreeRTOS/Demo/THOMAS_RISCV32_QEMU


# output
elf=${shell_folder}/FreeRTOS/FreeRTOS/Demo/THOMAS_RISCV32_QEMU/build/thomas_riscv32.elf

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
riscv32-unknown-elf-objdump -xD ${elf} > freertos.asm
