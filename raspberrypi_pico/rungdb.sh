#!/bin/bash

export PATH="/home/cn1396/.toolchain/gcc-arm-none-eabi-10.3-2021.07/bin/:$PATH"

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

elf=${shell_folder}/pico-examples/build/hello_world/serial/hello_serial.elf
#elf=${shell_folder}/pico-bootrom/build/bootrom.elf
symbol1=${shell_folder}/pico-bootrom/build/bootrom.elf
symbol2=${shell_folder}/pico-examples/build/pico-sdk/src/rp2_common/boot_stage2/bs2_default.elf
symbol3=${shell_folder}/FreeRTOS/FreeRTOS/Demo/CORTEX_M0+_RP2040/build/OnEitherCore/on_core_zero.elf
symbol4=${shell_folder}/FreeRTOS/FreeRTOS/Demo/CORTEX_M0+_RP2040/build/OnDualCore/on_dual_core.elf

# gdb
arm-none-eabi-gdb \
-ex 'target remote localhost:3333' \
-ex "load ${symbol4}" \
-ex "add-symbol-file ${symbol4}" \
-ex "add-symbol-file ${symbol1}" \
-ex "add-symbol-file ${symbol2}" \
-ex "monitor reset init" \
-q
