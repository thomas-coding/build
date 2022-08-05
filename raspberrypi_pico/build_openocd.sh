#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

# build makefile
cd ${shell_folder}/openocd
./bootstrap
./configure --enable-picoprobe
make -j4

