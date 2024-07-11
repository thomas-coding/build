#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/home/cn1396/workspace/code/riscv64_test/riscv/bin:$PATH"

opensbi_elf=${shell_folder}/opensbi/build/platform/generic/firmware/fw_payload.elf
uboot_elf=${shell_folder}/u-boot/u-boot
# dump
rm opensbi_elf.asm uboot_elf.asm
riscv64-unknown-linux-gnu-objdump -xD ${opensbi_elf} > opensbi_elf.asm
riscv64-unknown-linux-gnu-objdump -xD ${uboot_elf} > uboot_elf.asm