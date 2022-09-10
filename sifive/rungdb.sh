#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="${shell_folder}/toolchain/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14/bin:$PATH"

demo_elf=${shell_folder}/freedom-e-sdk/software/hello/debug/hello.elf

gdb_path=/home/cn1396/workspace/code/sifive/test/riscv32/bin
# gdb
# used gdb multiarch instead of riscv64-unknown-elf-gdb for tui
#gdb-multiarch \
${gdb_path}/riscv32-unknown-elf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${demo_elf}" \
-q 
