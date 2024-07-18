#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

rm -rf ${intermediate}/.config

# build command
if [[ ${build_command} == "defconfig" ]]; then
    if [[ ${buildroot_config} != "" ]]; then
        make ${buildroot_config} savedefconfig || exit 1
        mv defconfig configs/${buildroot_config}
    fi

    exit 0
fi

if [[ ${build_command} != "" ]]; then
    exit 0
fi

if [[ ${buildroot_distclean} == "y" ]]; then
    # distclean shall be before prepare dl packages
    make distclean || exit 1
fi

if [[ ${optee_home} != "" ]]; then
    rootfs_user_file=${out}/add_users.txt
    buildroot_option="${buildroot_option} BR2_ROOTFS_USERS_TABLES=${rootfs_user_file}"

    cat > ${rootfs_user_file} << EOF
tee -1 tee -1 * - /bin/sh - TEE user
- -1 teeclnt -1 - - - - TEE users group
- -1 ion -1 - - - - ION users group
EOF
fi

if [[ ${buildroot_config} != "" ]]; then
    make O=${intermediate} ${buildroot_config} || exit 1
    make -j${build_jobs} O=${intermediate} ${buildroot_option} || exit 1
fi

rootfs_image=${intermediate}/images/rootfs.cpio.gz

rm -rf ${out}/rootfs
mkdir ${out}/rootfs
cd ${out}/rootfs

# check rootfs image size, shall > 1Mbyte
filesize=$(stat -c%s ${rootfs_image})
if [[ ${filesize} == "" ]]; then
    echo "rootfs image does not exist"
    exit 1
fi

if [ "$filesize" -gt "1000000" ]; then
    gunzip ${rootfs_image} -c | fakeroot cpio -idm

    if [[ -f ${intermediate}/images/rootfs.ubifs ]]; then
        cp ${intermediate}/images/rootfs.ubifs ${imagedir}/${product}.ubifs
    fi
else
    echo "rootfs image is too small, maybe have an error"
    exit 1
fi
