#!/bin/bash

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin/:$PATH"

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

openocd=${shell_folder}/openocd/src/openocd
probe_config=${shell_folder}/openocd/tcl/interface/picoprobe.cfg
target_config=${shell_folder}/openocd/tcl/target/rp2040.cfg
source=${shell_folder}/openocd/tcl

cd ${shell_folder}
#sudo gdb --args ${openocd} -f ${probe_config} -f ${target_config} -s ${source} --debug
sudo ${openocd} -f ${probe_config} -f ${target_config} -s ${source}
 