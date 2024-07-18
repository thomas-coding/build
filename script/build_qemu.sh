#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

add_target ${base_home}/${qemu_binary} ${imagedir}

if [[ ${qemu_no_reconfig} != 1 ]]; then
    ./configure --target-list=${qemu_target} ${qemu_config_option}
fi

make -j${build_jobs} || exit 1
