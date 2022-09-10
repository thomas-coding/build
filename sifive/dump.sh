#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="${shell_folder}/toolchain/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14/bin:$PATH"

demo_elf=${shell_folder}/freedom-e-sdk/software/hello/debug/hello.elf

# dump
riscv64-unknown-elf-objdump -xD ${demo_elf} > hello.asm