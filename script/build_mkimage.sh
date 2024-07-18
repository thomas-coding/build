#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

# build command
if [[ ${build_command} != "" ]]; then
    exit 0
fi

# update rootfs
if [ -d ${out}/rootfs ]; then
    cd ${out}/rootfs || exit
    # static libraries not needed, but some modules install them in lazy
    # remove these .a files to reduce image size
    find . -name "*.a" -exec rm -rf {} \;
    find . | fakeroot cpio -o -H newc > ${imagedir}/rootfs.cpio
    gzip -f ${imagedir}/rootfs.cpio
    cd - > /dev/null
fi

# create final kernel image with initramfs
if [[ ${mkimage_tool} != "system" ]]; then
    export PATH=${uboot_home}/tools:$PATH
fi

# kernel is not mandantory in some cases, such as xen
if [[ ${kernel_home} != "" ]]; then
    if [[ ${kernel_initramfs} == "y" || ${kernel_image} == uImage ]]; then
        add_target ${intermediate_home}/kernel/arch/${ARCH}/boot/${kernel_image} ${imagedir}
        if [[ ${rootfs_provider} == "android" ]]; then
            target_ramdisk_img=${out}/ramdisk.cpio.gz
        else
            target_ramdisk_img=${imagedir}/rootfs.cpio.gz
        fi

        if [[ ${kernel_initramfs} == "y" ]]; then
            make O=${intermediate_home}/kernel -C ${kernel_home} ${kernel_image} -j${build_jobs} \
                CC="${kernel_cc_runtime}" CONFIG_INITRAMFS_SOURCE=${target_ramdisk_img}
            # for ramdisk, rootfs package not used anymore, remove it to avoid confusion
            rm -rf ${target_ramdisk_img}
        else
            make O=${intermediate_home}/kernel -C ${kernel_home} ${kernel_image} -j${build_jobs} \
                CC="${kernel_cc_runtime}"
        fi
    fi
fi

# Need verify and copy file now, since later steps depend on this
if ! do_verify_copy; then
    exit 1
fi

#mkimage_boot_type=uboot
#mkimage_boot_type=fip
#mkimage_boot_type=build
#mkimage_boot_type=uboot_fip
#mkimage_boot_type=uboot_itb

# create bootable image
if [[ ${mkimage_boot_type} == "uboot" ]]; then
    #combine uboot binary into bootable image binary
    cd ${mkimage_home}
    add_target ${mkimage_home}/flash.bin ${imagedir}
    cat ${uboot_spl} /dev/zero | head -c 359424 > new.bin
    cat new.bin u-boot.img > flash.bin
    rm -rf new.bin
elif [[ ${mkimage_boot_type} == "uboot_itb" ]]; then
    #combine uboot-spl binary and uboot fit itb binary
    cd ${mkimage_home}
    add_target ${mkimage_home}/flash.bin ${imagedir}
    cat ${uboot_spl} /dev/zero | head -c ${mkimage_spl_max_size} > new.bin
    cat new.bin u-boot.itb > flash.bin
    rm -rf new.bin
elif [[ ${mkimage_boot_type} == "fip" ]]; then
    #fip has moved to atf
    echo "use fip as bootable image"

    if [[ ${fbp_support} == "y" ]]; then
        cd ${mkimage_home}
        echo "create fbp bootloader image"
        add_target ${mkimage_home}/fbp-flash.bin ${imagedir}
        if [[ ${rootfs_provider} == "chromiumos" ]]; then
            add_target ${mkimage_home}/fbp-flash.bin ${chromiumos_uboot}
        fi
        cat fbp.bin /dev/zero | head -c 1048576 > fbp_bl2_padding.bin
        cat fbp_bl2_padding.bin fip.bin > fbp-flash.bin
    fi

elif [[ ${mkimage_boot_type} == "build" ]]; then
    #directly create boot flash binary
    add_target ${mkimage_home}/${SOC}/flash.bin ${imagedir}

    cd ${mkimage_home}

    make CONFIG_REMAKE_ELF=n V=1 SOC=${mkimage_soc} ${mkimage_opt} ${mkimage_target}

elif [[ ${mkimage_boot_type} == "uboot_fip" ]]; then
    cd ${imagedir}
    cat > fdisk_input << EOF
n
p
1
4096


t
1
c
w

EOF

    loop_dev=$(sudo losetup --find | awk -F '/' '{print $3}')
    if [[ ${loop_dev} == "" ]]; then
        exit 1
    fi

    dd if=/dev/zero of=uboot.img bs=1M count=64
    fdisk uboot.img < fdisk_input
    partprobe uboot.img
    fdisk -l uboot.img
    sudo losetup /dev/${loop_dev} uboot.img
    sudo kpartx -av /dev/${loop_dev}
    sudo mkfs.vfat /dev/mapper/${loop_dev}p1

    [ -d tmp ] || mkdir tmp
    sudo mount /dev/mapper/${loop_dev}p1 tmp/
    if [[ -d ${imagedir} ]] && [[ -f ${kernel_image} ]]; then
        sudo cp ${imagedir}/${kernel_image} tmp/
        sudo cp ${imagedir}/*.dtb tmp/
    fi

    sudo dd if=${mkimage_home}/${SOC}/fip.bin of=/dev/${loop_dev} bs=512 seek=40
    sync
    sudo umount tmp
    sudo kpartx -d /dev/${loop_dev}
    sudo losetup --detach /dev/${loop_dev}

    rmdir tmp
fi

# pack uboot fit image
if [[ -f ${out}/u-boot && ${uboot_fit} == "y" ]]; then
    echo "pack kernel and dtb into uboot fit image"
    cd ${imagedir}

    # fit need zImage
    if [ -f ${intermediate_home}/kernel/arch/${ARCH}/boot/${uboot_fit_kernel_image} ]; then
        cp ${intermediate_home}/kernel/arch/${ARCH}/boot/${uboot_fit_kernel_image} ${imagedir}
    else
        exit 1
    fi

    # mkimage needs its in current directory
    cp ${uboot_fit_its_dir}/${uboot_fit_its} .
    mkimage -f ${uboot_fit_its} ${uboot_fit_itb} && rm -rf ${uboot_fit_its}

    if [ -f ${imagedir}/${uboot_fit_itb} ]; then
        echo "FIT image create success"
    else
        exit 1
    fi
fi
