#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

cd ${shell_folder}/openocd
./bootstrap
./configure --enable-jlink CFLAGS='-g -O0'
make -j4
