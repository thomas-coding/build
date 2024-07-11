#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/home/cn1396/workspace/code/riscv64_test/riscv/bin:$PATH"
export CROSS_COMPILE=riscv64-unknown-linux-gnu-

cmd_help() {
	echo "Basic mode:"
	echo "$0 h			---> command help"
	echo "$0 a			---> make"
	echo "$0 c			---> make clean"
}
 
if [[ $1  = "h" ]]; then
	cmd_help
elif [[ $1  = "uboot" ]]; then
	cd ${shell_folder}/u-boot
	make qemu-riscv64_smode_defconfig
	make -j4
elif [[ $1  = "busybox" ]]; then
	#make defconfig
	make -j4
elif [[ $1  = "buildroot" ]]; then
	make qemu_riscv64_virt_defconfig
	make -j4
elif [[ $1  = "linux" ]]; then
	cd ${shell_folder}/linux
	#make ARCH=riscv defconfig
	make ARCH=riscv -j6
elif [[ $1  = "opensbi" ]]; then
	cd ${shell_folder}/opensbi
	rm -rf build
	#make PLATFORM=generic FW_PATLOAD_PATH=../u-boot/u-boot-nodtb.bin
	#make PLATFORM=generic PLATFORM_RISCV_XLEN=64 BUILD_INFO=y FW_PIC=n FW_PATLOAD_PATH=../u-boot/u-boot.bin
	make PLATFORM=generic PLATFORM_RISCV_XLEN=64
else
	echo "wrong args."
	cmd_help
fi
