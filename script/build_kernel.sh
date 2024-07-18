#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

# build command
if [[ ${build_command} == "clean" ]]; then
    rm -rf .config include/config include/generated arch/${ARCH}/include/generated
    rm -rf ${intermediate}/.config ${intermediate}/include/config \
        ${intermediate}/include/generated ${intermediate}arch/${ARCH}/include/generated
    exit 0
fi

if [[ ${build_command} == "defconfig" ]]; then
    if [[ ${rontfs_provider} != "android" ]]; then
        make O=${intermediate} CC="${CC}" ${kernel_config} savedefconfig || exit 1
        mv ${intermediate}/defconfig arch/${ARCH}/configs/${kernel_config}
    fi

    exit 0
fi

if [[ ${build_command} != "" ]]; then
    exit 0
fi

# Install kernel dtb files. if $kernel_dst_dtb specified, rename
# first src dtb as $kernel_dst_dtb and keep others
if [[ ${kernel_src_dtb} != "" ]]; then
    for item in ${kernel_src_dtb}; do
        if [[ ${kernel_dst_dtb} != "" ]]; then
            if [[ ${kernel_src_dtb_arch} != "" ]]; then
                add_target ${intermediate}/arch/${kernel_src_dtb_arch}/boot/dts/${item} ${imagedir}/${kernel_dst_dtb}
            else
                add_target ${intermediate}/arch/${ARCH}/boot/dts/${item} ${imagedir}/${kernel_dst_dtb}
            fi
        else
            add_target ${intermediate}/arch/${ARCH}/boot/dts/${item} ${imagedir}
        fi
    done
fi

# Install kernel extra dtb files.
if [[ ${kernel_extra_dtb} != "" ]]; then
    for item in ${kernel_extra_dtb}; do
        add_target ${intermediate}/arch/${ARCH}/boot/dts/${item} ${imagedir}/
    done
fi

if [[ ${kernel_initramfs} != "y" && ${kernel_image} != uImage ]]; then
    add_target ${intermediate}/arch/${ARCH}/boot/${kernel_image} ${imagedir}
fi

# add empty file .scm_version to avoid + in kernel version
touch .scmversion

make O=${intermediate} ${kernel_config} || exit 1
make O=${intermediate} -j${build_jobs} || exit 1

# build and install kernel modules
if [[ ${kernel_modules} == "y" ]]; then
    echo "make kernel modules"
    make O=${intermediate} -j${build_jobs} modules || exit 1

    kernel_modules_install_dir=${out}/rootfs

    make O=${intermediate} -j${build_jobs} modules_install \
        INSTALL_MOD_PATH=${kernel_modules_install_dir} || exit 1
fi

# build kernel perf and install
if [[ ${kernel_perf} == "y" ]]; then
    add_target_bin "${intermediate}/perf"

    # add extra kernel cflags
    if [[ ${KERNEL_EXTRA_CFLAGS} != "" ]]; then
        export EXTRA_CFLAGS=${KERNEL_EXTRA_CFLAGS}
    fi
    make O=${intermediate} CC="${CROSS_COMPILE}gcc" -j${build_jobs} NO_LIBPYTHON=1 -C tools/perf || exit 1
    ${CROSS_COMPILE}strip ${intermediate}/perf
fi
