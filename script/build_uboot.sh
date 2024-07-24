#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

rm -rf ${intermediate}/.config ${intermediate}/include/config

# build command
if [[ ${build_command} == "defconfig" ]]; then
    make O=${intermediate} ${uboot_config} savedefconfig || exit 1
    mv ${intermediate}/defconfig configs/${uboot_config}

    exit 0
elif [[ ${build_command} != "" ]]; then
    exit 0
fi



add_target \"${intermediate}/*.bin\" ${out}
add_target ${intermediate}/u-boot ${out}
add_target ${intermediate}/u-boot ${imagedir}

if [[ ${uboot_fip} = 1 ]]; then
    add_target ${intermediate}/fip.bin ${imagedir}
fi

make O=${intermediate} ${uboot_config} || exit 1
make O=${intermediate} -j${build_jobs} all || exit 1

if [[ ${uboot_fip} = 1 ]]; then
    make O=${intermediate} \
        FIPTOOLPATH=${fiptool_path} \
        OPENSBI=${opensbi} \
        UBOOT=${intermediate}/u-boot.bin \
        OPENSBI_DTB=${intermediate}/dts/dt.dtb \
        fip.bin || exit 1
fi

if [[ ${mkimage_home} != "" ]]; then
    if [ -f ${intermediate}/spl/u-boot-spl.bin ]; then
        cp ${intermediate}/spl/*.bin ${mkimage_home}/${SOC}
        cp ${intermediate}/spl/u-boot-spl ${mkimage_home}/${SOC}
        cp ${intermediate}/spl/u-boot-spl ${imagedir}
    fi

    if [ -f ${intermediate}/u-boot.itb ]; then
        cp ${intermediate}/u-boot.itb ${mkimage_home}/${SOC}
        cp ${intermediate}/u-boot.itb ${imagedir}
    fi

    if [ -f ${intermediate}/u-boot.img ]; then
        cp ${intermediate}/u-boot.img ${mkimage_home}/${SOC}
    fi
fi
