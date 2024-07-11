#!/bin/bash

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)
TX_SINGLE_MODE_NON_SECURE=n

if [[ $1  = "h" ]]; then
	exit
elif [[ $1  = "thomas_m3" ]]; then
    demo_dir=${shell_folder}/azure/platform/thomas_m3
    demo_elf=${demo_dir}/build/thomas_m3.elf

elif [[ $1  = "thomas_m33" ]]; then
    if [[ ${TX_SINGLE_MODE_NON_SECURE} = "y" ]]; then
        demo_dir=${shell_folder}/azure/platform/thomas_m33
        demo_elf=${demo_dir}/secure/build/thomas_m33_s.elf
        ns_demo_elf=${demo_dir}/build/thomas_m33.elf
    else
        demo_dir=${shell_folder}/azure/platform/thomas_m33
        demo_elf=${demo_dir}/build/thomas_m33.elf
    fi

else
	echo "Please specify project"
	cmd_help
	exit
fi

# gdb
arm-none-eabi-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${demo_elf}" \
-ex "add-symbol-file ${ns_demo_elf}" \
-q
