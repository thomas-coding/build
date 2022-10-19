#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)
export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"


if [[ $1  = "h" ]]; then
	exit
elif [[ $1  = "thomas_m3" ]]; then
    # which demo to compile
    platform_dir=${shell_folder}/azure/platform/thomas_m3

    # build
    cd "${platform_dir}" || exit
    rm -rf build
    cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../../threadx/cmake/cortex_m3.cmake -GNinja .
    cmake --build ./build
	exit
else
	echo "Please specify project"
	cmd_help
	exit
fi

