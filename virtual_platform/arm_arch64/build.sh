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
export ARCH=arm64
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

	# option
	atf_option_crash_report=0
	atf_option_secure_boot=0
	atf_option_secure_boot_encrypt=0
	atf_option_secure_debug=0

	atf_build_opt=
	atf_build_opt+=" ARCH=aarch64 "
	atf_build_opt+=" PLAT=a55 "
	atf_build_opt+=" CROSS_COMPILE=aarch64-none-elf- "
	atf_build_opt+=" SPD=opteed "
	atf_build_opt+=" BL32=${shell_folder}/optee/optee_os/build/core/tee-header_v2.bin "
	atf_build_opt+=" BL32_EXTRA1=${shell_folder}/optee/optee_os/build/core/tee-pager_v2.bin "
	atf_build_opt+=" BL32_EXTRA2=${shell_folder}/optee/optee_os/build/core/tee-pageable_v2.bin "
	atf_build_opt+=" BL33=${shell_folder}/u-boot/u-boot.bin "
	atf_build_opt+=" all fip "

    if [[ ${atf_option_secure_boot} = 1 ]]; then
        atf_build_opt+=" GENERATE_COT=1 "
        atf_build_opt+=" TRUSTED_BOARD_BOOT=1 "
        atf_build_opt+=" MBEDTLS_DIR=${shell_folder}/third_party/mbedtls "
    fi

    if [[ ${atf_option_secure_boot_encrypt} = 1 ]]; then
        atf_build_opt+=" ENCRYPT_BL31=1 "
        atf_build_opt+=" ENCRYPT_BL32=1 "
        atf_build_opt+=" ENCRYPT_BL2=1 "
        atf_build_opt+=" ENC_KEY=1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef "
        atf_build_opt+=" ENC_NONCE=1234567890abcdef12345678 "
        atf_build_opt+=" DECRYPTION_SUPPORT=aes_gcm "
    fi

    if [[ ${atf_option_crash_report} = 1 ]]; then
        atf_build_opt+=" ENABLE_ASSERTIONS=1 "
        atf_build_opt+=" ENABLE_BACKTRACE=1 "
        atf_build_opt+=" CRASH_REPORTING=1 "
    fi

    if [[ ${atf_option_secure_debug} = 1 ]]; then
        atf_build_opt+=" SECURE_DEBUG=1 "
    fi

	make clean ${atf_build_opt}

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
	cd ${shell_folder}/linux
	make a55_defconfig
	make -j8

	if [ $? -ne 0 ]; then
		echo "failed"
		exit
	else
		echo "succeed"
	fi

	rm -f vmlinux.asm
	${CROSS_COMPILE}objdump -xd vmlinux > vmlinux.asm

	finish_time=${SECONDS}
	duration=$((finish_time-start_time))
	elapsed_time="$((duration / 60))m $((duration % 60))s"
	echo -e  "linux used:${elapsed_time}"
}

build_rootfs() {
	echo "Build rootfs ..."
	start_time=${SECONDS}

	cd ${shell_folder}/buildroot
	make clean
	make a55_defconfig
	make

	if [ $? -ne 0 ]; then
		echo "failed"
		exit
	else
		echo "succeed"
	fi

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
		all_start_time=${SECONDS}
		build_qemu
		build_optee
		build_u-boot
		build_atf
		build_rootfs
		build_linux
		all_finish_time=${SECONDS}
		all_duration=$((all_finish_time-all_start_time))
		all_elapsed_time="$((all_duration / 60))m $((all_duration % 60))s"
		echo -e  "build all used:${all_elapsed_time}"
		exit
	else
		echo "wrong args."
		cmd_help
		exit
	fi
done
