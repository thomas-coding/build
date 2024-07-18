#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

cd ${imagedir}

#build command
if [[ ${build_command} != "" ]]; then
    exit 0
fi

#only support sd boot image type
if [[ ${burn_image_type} != "sd" ]]; then
    echo "Not supported boot image type"
    exit 0
fi

#create fastboot upgrade script for android
if [[ ${rootfs_provider} == "android" ]]; then
    fastboot_script=fastboot_upgrade.sh
    touch ${fastboot_script} && chmod +x ${fastboot_script}

    cat > ${fastboot_script} << EOF
#!/bin/bash

function printUsage()
{
    echo "Fastboot upgrade script usage:"
    echo "    1. power on board and press any key to stop at uboot console"
    echo "    2. input 'dhcp' in uboot console to get the ip address"
    echo "    3. input 'fastboot udp' in uboot to wait for host side connection"
    echo "    4. run script in image folder with:"
    echo "        './fastboot_upgrade.sh board_ip [image]'"
    echo "            board_ip: the board ip address got from step 2"
    echo "               image: optional, it can be 'boot' 'kernel' 'system' or 'vendor',"
    echo "                      all these images will be upgraded if it's not specified"
}

if [[ \$# != 1 ]] && [[ \$# != 2 ]]; then
    printUsage
    exit
fi

if [[ \$1 != [0-9]*.[0-9]*.[0-9]*.[0-9]* ]]; then
    printUsage
    exit
fi

if [[ \$2 != "" ]] && [[ \$2 != "boot" ]] && [[ \$2 != "kernel" ]] \\
        && [[ \$2 != "system" ]] && [[ \$2 != "vendor" ]]; then
    printUsage
    exit
fi

echo "----- upgrade android images with fastboot !!!"
echo ""

if [[ \$2 = "" ]] || [[ \$2 = "boot" ]]; then
echo "----- upgrade boot image start !"
fastboot -s udp:\$1 flash boot flash.bin
echo "----- upgrade boot image finish !"
echo ""
fi

if [[ \$2 = "" ]] || [[ \$2 = "kernel" ]]; then
echo "----- upgrade kernel image start !"
fastboot -s udp:\$1 flash kernel kernel.img
echo "----- upgrade kernel image finish !"
echo ""
fi

if [[ \$2 = "" ]] || [[ \$2 = "system" ]]; then
echo "----- upgrade system image start !"
fastboot -s udp:\$1 flash system system.img
echo "----- upgrade system image finish !"
echo ""
fi

if [[ \$2 = "" ]] || [[ \$2 = "vendor" ]]; then
echo "----- upgrade vendor image start !"
fastboot -s udp:\$1 flash vendor vendor.img
echo "----- upgrade vendor image finish !"
echo ""
fi

echo "----- upgrade android images done !!!"
EOF
fi

#create burn script
touch ${burn_script} && chmod +x ${burn_script}

#create bootable sd card
cat > ${burn_script} << EOF
#!/bin/bash

CUR_DIR=\`pwd\`
burn_boot_image=flash.bin
burn_kernel_image=${kernel_image}
burn_el2_bin=${el2_bin}
burn_el2_dtb=${el2_dtb}
burn_xen=${xen_enable}
burn_xen_multi_part=${xen_multi_part}

cmd_help() {
    echo "Basic mode:"
    echo "\$0 h ---> command help"
    echo "\$0 t ---> format sd card and install images"
}

if [ \$# != 1 -a \$# != 2 ]
then
    echo "wrong args."
    cmd_help
    exit
fi

if [ \$1 = "h" ]
then
    cmd_help
    exit
elif [ \$1 = "t" ]
then
    if [ \$# = 1 ]
    then
        echo "please input SD device file"
        exit 1
    else
        if [ ! -e \$2 ]
        then
            echo "\$2 does not exist..."
            exit 1
        else
            if [ \$2 = "/dev/sda" ]; then
                echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                echo "YOU HAVE INPUT /dev/sda, MAYBE YOUR HOST ROOT DEVICE, NOT ALLOWED"
                echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                exit 1
            fi
            capacity=\$(sudo fdisk -l | grep \$2 | grep GiB | cut -d ' ' -f 3)
            if ((\${capacity%%.*} > 100)); then
                echo "Disk \$2 capacity is larger than 100GiB. Please check whether it is hard disk!!!"
                exit 1
            fi
        fi
    fi
else
    echo "wrong args."
    cmd_help
    exit
fi
EOF

#format sd card and install system images
if [[ ${rootfs_provider} == "android" ]]; then
    #For android usage
    cat >> ${burn_script} << EOF

cat > fdisk_input <<EOF1
print
mklabel gpt
mkpart boot_a ${burn_image_offset}s 102399s
mkpart kernel_a 102400s 1150975s
mkpart system_a 1150976s 4296703s
mkpart vendor_a 4296704s 6393855s
mkpart userdata_a 6393856s 100%
quit
EOF1

TARGET_DEV=\$2

if [[ "\${TARGET_DEV}" == "/dev/sd"* ]]; then
    TARGET_PARTITION=\${TARGET_DEV}
else
    TARGET_PARTITION=\${TARGET_DEV}p
fi

echo "----- clear old partition table on \${TARGET_DEV}:\{TARGET_PARTITION}"
sudo umount \${TARGET_PARTITION}1
sudo umount \${TARGET_PARTITION}2
sudo umount \${TARGET_PARTITION}3
sudo umount \${TARGET_PARTITION}4
sudo umount \${TARGET_PARTITION}5
sudo dd if=/dev/zero of=\${TARGET_DEV} bs=512 count=1

echo "----- create new partitions"
sudo parted \${TARGET_DEV} <fdisk_input
sudo partprobe \${TARGET_DEV}
sudo fdisk -l \${TARGET_DEV}

echo "----- make file system"
sudo mkfs.ext4 -L userdata \${TARGET_PARTITION}5 -F

echo "----- Write boot partition"
sudo dd if=flash.bin of=\${TARGET_PARTITION}1 bs=1M

echo "----- Write kernel partition"
sudo dd if=kernel.img of=\${TARGET_PARTITION}2 bs=1M

echo "----- Write system partition"
sudo dd if=system.img of=\${TARGET_PARTITION}3 bs=1M

echo "----- Write vendor partition"
sudo dd if=vendor.img of=\${TARGET_PARTITION}4 bs=1M

rm fdisk_input
exit 0
EOF
elif [[ ${xen_multi_part} == "y" ]]; then
    # For Xen multi partition
    cat >> ${burn_script} << EOF

cat > fdisk_input <<EOF1
n
p
1
102400
+1G
n
p
2
2199552
+12G
n
p
3
27365376

t
1
c
w

EOF1

TARGET_DEV=\$2

if [[ "\${TARGET_DEV}" == "/dev/sd"* ]]; then
    TARGET_PARTITION=\${TARGET_DEV}
else
    TARGET_PARTITION=\${TARGET_DEV}p
fi

echo "----- clear old partition table on \${TARGET_DEV}:\${TARGET_PARTITION}"
sudo umount \${TARGET_PARTITION}1
sudo umount \${TARGET_PARTITION}2
sudo umount \${TARGET_PARTITION}3
sudo dd if=/dev/zero of=\${TARGET_DEV} bs=512 count=1

echo "----- create new partitions"
sudo fdisk \${TARGET_DEV} <fdisk_input
sudo partprobe \${TARGET_DEV}
sudo fdisk -l \${TARGET_DEV}

echo "----- make file system"
sudo mkfs.vfat \${TARGET_PARTITION}1
sudo mkfs.ext4 \${TARGET_PARTITION}2 -F
sudo mkfs.ext4 \${TARGET_PARTITION}3 -F
EOF
else
    #For default usage
    cat >> ${burn_script} << EOF

sudo dd if=\${burn_boot_image} of=\$2 bs=512 conv=fsync,notrunc seek=${burn_image_offset}
sudo sync

cat > fdisk_input <<EOF1
n
p
1
102400
+1G
n
p
2
2199552

t
1
c
w

EOF1

TARGET_DEV=\$2

if [[ "\${TARGET_DEV}" == "/dev/sd"* ]]; then
    TARGET_PARTITION=\${TARGET_DEV}
else
    TARGET_PARTITION=\${TARGET_DEV}p
fi

echo "----- clear old partition table on \${TARGET_DEV}:\${TARGET_PARTITION}"
sudo umount \${TARGET_PARTITION}1
sudo umount \${TARGET_PARTITION}2
sudo dd if=/dev/zero of=\${TARGET_DEV} bs=512 count=1

echo "----- create new partitions"
sudo fdisk \${TARGET_DEV} <fdisk_input
sudo partprobe \${TARGET_DEV}
sudo fdisk -l \${TARGET_DEV}

echo "----- make file system"
sudo mkfs.vfat \${TARGET_PARTITION}1
sudo mkfs.ext4 \${TARGET_PARTITION}2 -F
EOF
fi

#install kernel and dtb images
cat >> ${burn_script} << EOF

rm fdisk_input

echo "----- copy uImage and dtb"
tmpdir=\`mktemp -d\`
if [[ "\${tmpdir}" != "/tmp/tmp."* ]]; then
    echo "create tmp directory error"
    exit 1
fi

sudo mount -t vfat \${TARGET_PARTITION}1 \${tmpdir}

if [[ "\${burn_xen_multi_part}" = "y" ]]; then
    echo "----- install xen, dom0 and domU images"
    sudo cp -f xen \${tmpdir}
    sudo cp -f -r --no-preserve=mode,ownership pv-config domU \${tmpdir}
    sudo cp -f -r dom0/* \${tmpdir}
elif [[ "\${burn_xen}" = "y" ]]; then
    echo "----- install xen, dom0 and domU images"
    sudo cp -f xen boot.scr \${tmpdir}
    sudo cp -f -r --no-preserve=mode,ownership pv-config dom0 domU \${tmpdir}
    sudo umount \${tmpdir}
    rm fdisk_input
    exit 0
else
    sudo cp -f -r * \${tmpdir}

    if [ "\${burn_el2_bin}" != "" ]; then
        if [ -f \${burn_el2_bin} ]; then
            sudo cp -f \${burn_el2_bin} \${tmpdir}
        fi
    fi

    if [ "\${burn_el2_dtb}" != "" ]; then
        if [ -f \${burn_el2_dtb} ]; then
            sudo cp -f \${burn_el2_dtb} \${tmpdir}
        fi
    fi
fi

sudo umount \${tmpdir}

echo "----- install image done"
EOF

#no need to install rootfs for initramfs image
if [[ ${kernel_initramfs} == "y" || ${rootfs_skip_image} == "y" ]]; then
    exit 0
fi

cat >> ${burn_script} << EOF

echo "----- create root file system"
sudo mount -t ext4 \${TARGET_PARTITION}2 \${tmpdir}
sudo rm -rf \${tmpdir}/*
cd \${tmpdir}
sudo gunzip -k -f \${CUR_DIR}/rootfs.cpio.gz
sudo cpio -idm < \${CUR_DIR}/rootfs.cpio
rm -rf \${CUR_DIR}/rootfs.cpio
cd -

sudo umount \${tmpdir}

if [[ "\${burn_xen_multi_part}" = "y" ]]; then
    echo "----- install DomU rootfs"
    sudo mount -t ext4 \${TARGET_PARTITION}3 \${tmpdir}
    sudo rm -rf \${tmpdir}/*
    cd \${tmpdir}
    sudo gunzip -k -f \${CUR_DIR}/domU/rootfs.cpio.gz
    sudo cpio -idm < \${CUR_DIR}/domU/rootfs.cpio
    rm -rf \${CUR_DIR}/domU/rootfs.cpio
    cd -

    sudo umount \${tmpdir}
fi

rm -rf \${tmpdir}
echo "----- install rootfs done"

EOF

# Create qemu script
if [[ ${burn_qemu_script} != "" ]]; then

    touch ${burn_qemu_script} && chmod +x ${burn_qemu_script}

cat > ${burn_qemu_script} << EOF
#!/bin/bash

# Shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

qemu_option=
if [[ \$1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
fi

qemu_option+="${burn_qemu_opt}"

./${burn_qemu_binary} \${qemu_option}

EOF

fi

# Create gdb script
if [[ ${burn_gdb_script} != "" ]]; then

    touch ${burn_gdb_script} && chmod +x ${burn_gdb_script}

cat > ${burn_gdb_script} << EOF
#!/bin/bash

export PATH="${toolchain_path}/${toolchain}/bin:\$PATH"

${burn_gdb_binary} ${burn_gdb_opt}

EOF

fi

# Create dump script
if [[ ${burn_dump_script} != "" ]]; then

    touch ${burn_dump_script} && chmod +x ${burn_dump_script}

cat > ${burn_dump_script} << EOF
#!/bin/bash

export PATH="${toolchain_path}/${toolchain}/bin:\$PATH"

${burn_dump_binary} ${burn_dump_opt}

EOF

fi