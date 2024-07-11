#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

platform_dir=${shell_folder}/peaks

# build
cd "${platform_dir}" || exit
rm -rf build

# Module to build
scons --build=r_crc --board=ra4m3_ek --compiler=gcc --skip_srec_check

# Module to build
#scons --build=rm_freertos_port --board=ra4m3_ek --compiler=gcc --skip_srec_check
