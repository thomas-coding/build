#!/bin/bash

# Shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/root/workspace/software/qemu/qemu-6.0.0/build/:$PATH"

# boot source
boot_from_sd=1

# support display
display_enable=0

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine thomas-a55"
qemu_option+=" -kernel ${shell_folder}/arm-trusted-firmware/build/a55/release/bl1/bl1.elf"
qemu_option+=" -device loader,file=${shell_folder}/buildroot/output/images/rootfs.tar,addr=0x37000000"
#qemu_option+=" -d guest_errors"
qemu_option+=" -drive file=${shell_folder}/virtio.disk,format=raw,id=virtio_blk"
qemu_option+=" -device virtio-blk-device,drive=virtio_blk"
qemu_option+=" -global virtio-mmio.force-legacy=false"

# Virtual gateway
qemu_option+=" -netdev user,id=net0,\
net=192.168.31.0/24,\
host=192.168.31.254,\
dns=192.168.31.250,\
dhcpstart=192.168.31.100,\
hostfwd=tcp:127.0.0.1:3522-192.168.31.100:22,\
hostfwd=tcp:127.0.0.1:3580-192.168.31.100:80"

# Guest virtual net card
qemu_option+=" -device virtio-net-device,netdev=net0"
#qemu_option+=" -netdev user,net=192.168.31.0/24,host=192.168.31.2,hostname=qemu,dns=192.168.31.56,dhcpstart=192.168.31.100,hostfwd=tcp::3522-:22,hostfwd=tcp::3580-:80,id=net0"

qemu_option+=" -smp 2"

if [[ ${display_enable} = 1 ]]; then
    qemu_option+=" -device virtio-gpu-device"
    # Connect from vnc for display: 10.10.13.190:5902
    qemu_option+=" -vnc :2"
    # connect like: telnet localhost 3441
    qemu_option+=" --serial telnet:127.0.0.1:3441,server,nowait"
else
    qemu_option+=" -nographic"
fi

if [[ ${boot_from_sd} = 1 ]]; then
    qemu_option+=" -drive if=sd,file=${shell_folder}/sd.disk,format=raw"
else
    qemu_option+=" -device loader,file=${shell_folder}/arm-trusted-firmware/build/a55/release/fip.bin,addr=0x21000000"
    qemu_option+=" -device loader,file=${shell_folder}/linux/arch/arm64/boot/Image,addr=0x34000000"
    qemu_option+=" -device loader,file=${shell_folder}/linux/arch/arm64/boot/dts/virtual_platform/a55.dtb,addr=0x36000000"
fi

# Change to develop qemu
#gdb --args qemu/build/arm-softmmu/qemu-system-arm -d in_asm,out_asm,cpu ${qemu_option}

qemu/build/aarch64-softmmu/qemu-system-aarch64 ${qemu_option}
