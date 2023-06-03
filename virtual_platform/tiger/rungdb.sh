#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)


export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-elf/bin/:$PATH"

#-ex "add-symbol-file ${shell_folder}/linux/vmlinux -s .head.text 0x32000000 -s .text 0x32010000 -s .init.text 0x323b0000"
#-ex "add-symbol-file ${shell_folder}/ramfs/image/init"
#-ex "add-symbol-file ${shell_folder}/optee/optee_test/out/xtest/xtest"
#-ex "add-symbol-file ${shell_folder}/baremetal/a55/output/a55.elf"

# gdb
aarch64-none-elf-gdb \
-ex 'target remote localhost:1234' \
-ex "set confirm off" \
-ex "add-symbol-file ${shell_folder}/out/x5/intermediate/atf/horizon/release/bl1/bl1.elf" \
-ex "add-symbol-file ${shell_folder}/out/x5/intermediate/atf/horizon/release/bl2/bl2.elf" \
-ex "add-symbol-file ${shell_folder}/out/x5/intermediate/atf/horizon/release/bl31/bl31.elf" \
-ex "add-symbol-file ${shell_folder}/out/x5/intermediate/kernel/vmlinux" \
-q
 