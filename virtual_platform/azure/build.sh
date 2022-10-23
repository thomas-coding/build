#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)
export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin:$PATH"

TX_SINGLE_MODE_NON_SECURE=n

if [[ $1  = "h" ]]; then
	exit
elif [[ $1  = "thomas_m3" ]]; then
    # which demo to compile
    platform_dir=${shell_folder}/azure/platform/thomas_m3

    # build
    cd "${platform_dir}" || exit
    rm -rf build
    cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../cmake/cortex_m3.cmake -GNinja .
    cmake --build ./build
	exit
elif [[ $1  = "thomas_m33" ]]; then

    if [[ ${TX_SINGLE_MODE_NON_SECURE} = "y" ]]; then
        # secure elf
        platform_dir=${shell_folder}/azure/platform/thomas_m33/secure
        # build
        cd "${platform_dir}" || exit
        rm -rf build
        cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../../cmake/cortex_m33.cmake -GNinja .
        cmake --build ./build
    fi

    # Threadx
    platform_dir=${shell_folder}/azure/platform/thomas_m33
    # build
    cd "${platform_dir}" || exit
    rm -rf build
    cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../cmake/cortex_m33.cmake -GNinja .
    cmake --build ./build
	exit
else
	echo "Please specify project"
	cmd_help
	exit
fi

