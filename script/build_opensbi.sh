#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

# build command
if [[ ${build_command} == "clean" ]]; then
    make clean
    exit 0
fi

if [[ ${build_command} != "" ]]; then
    exit 0
fi

add_target ${intermediate}/platform/${opensbi_platform}/firmware/fw_jump.bin ${imagedir}
add_target ${intermediate}/platform/${opensbi_platform}/firmware/fw_jump.elf ${imagedir}

# build
if [[ ${opensbi_build_info} == 1 ]]; then
    NEED_BUILD_INFO=y
fi

make O=${intermediate} \
    PLATFORM=${opensbi_platform} \
    PLATFORM_RISCV_XLEN=${opensbi_riscv_xlen} \
    FW_TEXT_START=${opensbi_fw_text_start} \
    FW_JUMP_ADDR=${opensbi_fw_jump_addr} \
    BUILD_INFO=${NEED_BUILD_INFO} || exit 1

if [[ ${opensbi_build_doc} == 1 ]]; then
    make O=${intermediate} docs
fi
