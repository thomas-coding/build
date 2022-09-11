#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export RISCV_OPENOCD_PATH=~/.toolchain/sifive/riscv-openocd-0.10.0-2020.12.1-x86_64-linux-ubuntu14
export RISCV_PATH=~/.toolchain/sifive/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14

cd ${shell_folder}/freedom-e-sdk
make PROGRAM=hello TARGET=qemu-sifive-e31 CONFIGURATION=debug software


