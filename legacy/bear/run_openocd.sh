#!/bin/bash

# Shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

cd ${shell_folder}/openocd
./src/openocd
