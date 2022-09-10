#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export RISCV_OPENOCD_PATH=${shell_folder}/openocd/riscv-openocd-0.10.0-2020.12.1-x86_64-linux-ubuntu14
export RISCV_PATH=${shell_folder}/toolchain/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14
export PATH=$PATH:${shell_folder}/qemu/riscv-qemu-5.1.0-2020.08.1-x86_64-linux-ubuntu14/bin

cd ${shell_folder}/freedom-e-sdk
make PROGRAM=hello TARGET=qemu-sifive-e31 CONFIGURATION=debug software


