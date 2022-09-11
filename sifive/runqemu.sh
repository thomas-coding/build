#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export RISCV_OPENOCD_PATH=${shell_folder}/openocd/riscv-openocd-0.10.0-2020.12.1-x86_64-linux-ubuntu14
export RISCV_PATH=${shell_folder}/toolchain/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14
export PATH=$PATH:${shell_folder}/qemu/riscv-qemu-5.1.0-2020.08.1-x86_64-linux-ubuntu14/bin

# which demo to run
demo_elf=${shell_folder}/freedom-e-sdk/software/hello/debug/hello.elf

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine sifive_e"
qemu_option+=" -kernel ${demo_elf}"
qemu_option+=" -nographic"

# run qemu
qemu/build/riscv32-softmmu/qemu-system-riscv32 ${qemu_option}
