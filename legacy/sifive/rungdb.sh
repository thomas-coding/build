#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/home/cn1396/.toolchain/riscv/riscv32/bin:$PATH"

demo_elf=${shell_folder}/freedom-e-sdk/software/hello/debug/hello.elf

gdb_path=/home/cn1396/workspace/code/sifive/test/riscv32/bin
# gdb
# used gdb multiarch instead of riscv64-unknown-elf-gdb for tui
#gdb-multiarch \
${gdb_path}/riscv32-unknown-elf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${demo_elf}" \
-q 
