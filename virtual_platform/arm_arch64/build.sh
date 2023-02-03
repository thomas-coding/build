#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

# For toolchain
# Baremetal
export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-elf/bin/:$PATH"
# Linux 32
export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/:$PATH"
# Linux 64
export PATH="/home/cn1396/.toolchain/arm-gnu-toolchain-12.2.rel1-x86_64-aarch64-none-linux-gnu/bin/:$PATH"

# For mkimage tool make uImage
export PATH="/root/workspace/code/virtual_platform/u-boot/tools:$PATH"

# For cross compile
export ARCH=arm
export CROSS_COMPILE=aarch64-none-linux-gnu-

cmd_help() {
	echo "Basic mode:"
	echo "$0 h			---> Command help"
	echo "$0 qemu		---> Build qemu"
	echo "$0 u-boot		---> Build u-boot"
	echo "$0 linux		---> Build linux"
	echo "$0 atf		---> Build arm trusted firmware "
	echo "$0 rootfs		---> Build rootfs "
	echo "$0 all		---> Build all "
}

build_qemu() {
	echo "Build qemu ..."
	start_time=${SECONDS}

	cd ${shell_folder}/qemu
	./configure --target-list=aarch64-softmmu --enable-debug
	make -j8

	if [ $? -ne 0 ]; then
		echo "failed"
		exit
	else
		echo "succeed"
	fi

	finish_time=${SECONDS}
	duration=$((finish_time-start_time))
	elapsed_time="$((duration / 60))m $((duration % 60))s"
	echo -e  "Qemu used:${elapsed_time}"
}

build_atf() {
	echo "Build atf ..."
	start_time=${SECONDS}

	cd ${shell_folder}/arm-trusted-firmware
	rm -rf build

	make \
		ARCH=aarch64 \
		PLAT=a55 \
		CROSS_COMPILE=aarch64-none-elf- \
		DEBUG=1	\
		SPD=opteed \
		BL32=${shell_folder}/optee/optee_os/build/core/tee-header_v2.bin \
		BL32_EXTRA1=${shell_folder}/optee/optee_os/build/core/tee-pager_v2.bin \
		BL32_EXTRA2=${shell_folder}/optee/optee_os/build/core/tee-pageable_v2.bin \
		BL33=${shell_folder}/u-boot/u-boot.bin \
		all fip

	if [ $? -ne 0 ]; then
		echo "failed"
		exit
	else
		echo "succeed"
	fi

	finish_time=${SECONDS}
	duration=$((finish_time-start_time))
	elapsed_time="$((duration / 60))m $((duration % 60))s"
	echo -e  "ATF used:${elapsed_time}"
}

build_optee() {
	echo "Build optee ..."
	start_time=${SECONDS}

	cd ${shell_folder}/optee/optee_os
	rm -rf build

	make \
		CFG_TEE_BENCHMARK=n \
		CFG_TEE_CORE_LOG_LEVEL=3 \
		CROSS_COMPILE=aarch64-none-linux-gnu- \
		CROSS_COMPILE_core=aarch64-none-linux-gnu- \
		CROSS_COMPILE_ta_arm32=arm-none-linux-gnueabihf- \
		CROSS_COMPILE_ta_arm64=aarch64-none-linux-gnu- \
		DEBUG=1 \
		O=build \
		PLATFORM=virtual_platform \
		PLATFORM_FLAVOR=a55

	if [ $? -ne 0 ]; then
		echo "failed"
		exit
	else
		echo "succeed"
	fi

	finish_time=${SECONDS}
	duration=$((finish_time-start_time))
	elapsed_time="$((duration / 60))m $((duration % 60))s"
	echo -e  "optee used:${elapsed_time}"
}

build_u-boot() {
	echo "Build u-boot ..."
	start_time=${SECONDS}

	cd ${shell_folder}/u-boot
	make clean
	make a55_defconfig
	make

	if [ $? -ne 0 ]; then
		echo "failed"
		exit
	else
		echo "succeed"
	fi

	rm -f u-boot.asm
	${CROSS_COMPILE}objdump -xd u-boot > u-boot.asm

	finish_time=${SECONDS}
	duration=$((finish_time-start_time))
	elapsed_time="$((duration / 60))m $((duration % 60))s"
	echo -e  "u-boot used:${elapsed_time}"
}

build_linux() {
	echo "Build linux ..."
	start_time=${SECONDS}
	# used for make uImage
	export LOADADDR=0x21008000
	cd ${shell_folder}/linux
	make a15_defconfig
	make

	if [ $? -ne 0 ]; then
		echo "failed"
		exit
	else
		echo "succeed"
	fi

	make -j2 uImage
	rm -f vmlinux.asm
	${CROSS_COMPILE}objdump -xd vmlinux > vmlinux.asm
	${CROSS_COMPILE}objdump -xd arch/arm/boot/compressed/vmlinux > arch/arm/boot/compressed/vmlinux.asm

	finish_time=${SECONDS}
	duration=$((finish_time-start_time))
	elapsed_time="$((duration / 60))m $((duration % 60))s"
	echo -e  "linux used:${elapsed_time}"
}

build_rootfs() {
	echo "Build rootfs ..."
	start_time=${SECONDS}

	cd ${shell_folder}/buildroot
	make a15_defconfig
	make

	if [ $? -ne 0 ]; then
		echo "failed"
		exit
	else
		echo "succeed"
	fi

	rm -f output/images/rootfs.cpio.uboot
	mkimage -A arm -O linux -T ramdisk -C none -a 0x2c000000 -n "ramdisk" -d  output/images/rootfs.cpio output/images/rootfs.cpio.uboot

	finish_time=${SECONDS}
	duration=$((finish_time-start_time))
	elapsed_time="$((duration / 60))m $((duration % 60))s"
	echo -e  "rootfs used:${elapsed_time}"
}

for arg in $*
do
	if [[ $arg  = "h" ]]; then
	cmd_help
	elif [[ $arg  = "qemu" ]]; then
	build_qemu
	elif [[ $arg  = "atf" ]]; then
	build_atf
	elif [[ $arg  = "optee" ]]; then
	build_optee
	elif [[ $arg  = "uboot" ]]; then
	build_u-boot
	elif [[ $arg  = "linux" ]]; then
	build_linux
	elif [[ $arg  = "rootfs" ]]; then
	build_rootfs
	elif [[ $arg  = "all" ]]; then
	build_qemu
	build_atf
	build_optee
	build_u-boot
	build_linux
	build_rootfs
	exit
else
	echo "wrong args."
	cmd_help
	exit
fi
done
