#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

TX_SINGLE_MODE_NON_SECURE=n

qemu_option=
if [[ $2  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

if [[ $1  = "h" ]]; then
	exit
elif [[ $1  = "thomas_m3" ]]; then
    demo_dir=${shell_folder}/azure/platform/thomas_m3
    qemu_option+=" -machine thomas-m3"
    qemu_option+=" -kernel ${demo_dir}/build/thomas_m3.elf"

elif [[ $1  = "thomas_m33" ]]; then
    if [[ ${TX_SINGLE_MODE_NON_SECURE} = "y" ]]; then
        demo_dir=${shell_folder}/azure/platform/thomas_m33
        qemu_option+=" -machine thomas-m33"
        qemu_option+=" -kernel ${demo_dir}/secure/build/thomas_m33_s.elf"
        qemu_option+=" -device loader,file=${demo_dir}/build/thomas_m33.bin,addr=0x10200000"
    else
        demo_dir=${shell_folder}/azure/platform/thomas_m33
        qemu_option+=" -machine thomas-m33"
        qemu_option+=" -kernel ${demo_dir}/build/thomas_m33.elf"
    fi
else
	echo "Please specify project"
	cmd_help
	exit
fi

qemu_option+=" -serial stdio"

# run qemu
qemu/build/qemu-system-arm ${qemu_option}
