#!/bin/bash

# Shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

#opensbi_image=${shell_folder}/opensbi/build/platform/generic/firmware/fw_payload.elf
opensbi_image=${shell_folder}/opensbi/build/platform/generic/firmware/fw_jump.bin
uboot_image=${shell_folder}/u-boot/u-boot-nodtb.bin

qemu_option+=" -machine virt -semihosting"
qemu_option+=" --semihosting-config enable=on,target=native"
#qemu_option+=" -bios default"
qemu_option+=" -bios ${opensbi_image}"
qemu_option+=" -serial stdio -nographic -m 1024"
qemu_option+=" -monitor telnet:127.0.0.1:65530,server,nowait"
qemu_option+=" -kernel ${uboot_image}"
qemu_option+=" -smp 2"

# Run qemu
#qemu-system-riscv64 ${qemu_option}
qemu/build/riscv64-softmmu/qemu-system-riscv64 -d guest_errors ${qemu_option} \
     -append "root=/dev/vda ro console=ttyS0" \
     -drive file=busybox/busybox,format=raw,id=hd0 \
     -device virtio-blk-device,drive=hd0

