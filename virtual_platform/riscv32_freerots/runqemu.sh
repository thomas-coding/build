#!/bin/bash

# Shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/root/.toolchain/riscv/bin:$PATH"

elf_dir=FreeRTOS/FreeRTOS/Demo/THOMAS_RISCV32_QEMU/build

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine thomas-riscv32 -bios none -monitor null -semihosting"
qemu_option+=" --semihosting-config enable=on,target=native"
qemu_option+=" -kernel ${shell_folder}/${elf_dir}/thomas_riscv32.elf"
qemu_option+=" -serial stdio -nographic"
qemu_option+=" -monitor telnet:127.0.0.1:65530,server,nowait"
#qemu_option+=" -smp 2"

# Run qemu
#qemu-system-riscv64 ${qemu_option}
qemu/build/riscv32-softmmu/qemu-system-riscv32 ${qemu_option}
#qemu_new/qemu/build/qemu-system-riscv32 ${qemu_option}


