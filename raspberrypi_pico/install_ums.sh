#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

pico_ums=/media/cn1396/RPI-RP2

# which binary to install
uf2=${shell_folder}/pico-examples/build/hello_world/serial/hello_serial.uf2
#uf2=${shell_folder}/picoprobe/build/picoprobe.uf2

# copy
cp ${uf2} ${pico_ums}

