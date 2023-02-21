#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

source ${shell_folder}/config.sh

# For toolchain
# Baremetal
export PATH="${toolchain_bm}/bin/:$PATH"
# Linux 32
export PATH="${toolchain_linux_32}/bin/:$PATH"
# Linux 64
export PATH="${toolchain_linux_64}/bin/:$PATH"

# For cross compile
export ARCH=arm64
export CROSS_COMPILE=aarch64-none-linux-gnu-

cmd_help() {
	echo "Basic mode:"
	echo "$0 h			---> Command help"
	echo "$0 qemu		---> Build qemu"
	echo "$0 u-boot		---> Build u-boot"
	echo "$0 kernel		---> Build linux kernel"
	echo "$0 atf		---> Build arm trusted firmware "
	echo "$0 rootfs		---> Build rootfs "
	echo "$0 mkimage	---> Copy thing to rootfs and pack. Copy images"
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

	# build optee os
	make \
		ARCH=arm \
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

	# build optee clinet
	cd ${shell_folder}/optee/optee_client
	rm -rf out
	make CROSS_COMPILE=aarch64-none-linux-gnu-

	# build optee example hello_world ta
	export TA_DEV_KIT_DIR=${shell_folder}/optee/optee_os/build/export-ta_arm64
	cd ${shell_folder}/optee/optee_examples/hello_world/ta
	make CROSS_COMPILE=aarch64-none-linux-gnu-

	# build optee example hello_world ca
	cd ${shell_folder}/optee/optee_examples/hello_world/host
	make \
		CROSS_COMPILE=aarch64-none-linux-gnu- \
		TEEC_EXPORT=${shell_folder}/optee/optee_client/out/export/usr \
		--no-builtin-variables

	# build optee xtest
	cd ${shell_folder}/optee/optee_test
	make \
		CROSS_COMPILE=aarch64-none-linux-gnu- \
		TA_DEV_KIT_DIR=${shell_folder}/optee/optee_os/build/export-ta_arm64 \
		OPTEE_CLIENT_EXPORT=${shell_folder}/optee/optee_client/out/export/usr \
		CROSS_COMPILE=${CROSS_COMPILE} \
		CFG_TEE_TA_LOG_LEVEL=3

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

build_kernel() {
	echo "Build kernel ..."
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
	echo -e  "linux kernel used:${elapsed_time}"
}

build_rootfs() {
	echo "Build rootfs ..."
	start_time=${SECONDS}

	# add tee user
	rootfs_user_file=${shell_folder}/out/add_users.txt
	cat > ${rootfs_user_file} <<EOF
tee -1 tee -1 * - /bin/sh - TEE user
- -1 teeclnt -1 - - - - TEE users group
EOF

	cd ${shell_folder}/buildroot
	make clean
	make a55_defconfig
	make \
		BR2_ROOTFS_USERS_TABLES=${rootfs_user_file} \
		BR2_TOOLCHAIN_EXTERNAL_PATH=${toolchain_linux_64} \
		BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX="aarch64-none-linux-gnu"

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

build_mkimage() {
	echo "Build make image ..."
	start_time=${SECONDS}

	# Get rootfs and copy to out
	cd ${shell_folder}/out/rootfs
	fakeroot cpio -idmv < ${shell_folder}/buildroot/output/images/rootfs.cpio

	# Make dir
	tee_supplicant_dir=${shell_folder}/out/rootfs/usr/sbin
	target_ta_dir=${shell_folder}/out/rootfs/lib/optee_armtz
	if [[ ! -d ${tee_supplicant_dir} ]];then
		mkdir -p ${tee_supplicant_dir}
	fi

	if [[ ! -d ${target_ta_dir} ]];then
		mkdir -p ${target_ta_dir}
	fi

	# Copy optee clinet
	cp ${shell_folder}/optee/optee_client/out/export/usr/sbin/tee-supplicant ${tee_supplicant_dir}
	cp ${shell_folder}/optee/optee_client/out/export/usr/lib/* ${shell_folder}/out/rootfs/usr/lib
	cp ${shell_folder}/optee/build/br-ext/package/optee_client_ext/S30optee ${shell_folder}/out/rootfs/etc/init.d

	# Copy optee xtest
	cp ${shell_folder}/optee/optee_test/out/ta/*/*.ta ${target_ta_dir}
	cp ${shell_folder}/optee/optee_test/out/xtest/xtest ${shell_folder}/out/rootfs/usr/bin

	# Copy optee hello world sample
	cp ${shell_folder}/optee/optee_examples/hello_world/ta/8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta ${target_ta_dir}
	cp ${shell_folder}/optee/optee_examples/hello_world/host/optee_example_hello_world ${shell_folder}/out/rootfs/usr/bin

	# Copy images
	rm -rf ${shell_folder}/out/images/*
	cp ${shell_folder}/arm-trusted-firmware/build/a55/release/fip.bin ${shell_folder}/out/images
	cp ${shell_folder}/linux/arch/arm64/boot/Image ${shell_folder}/out/images
	cp ${shell_folder}/linux/arch/arm64/boot/dts/virtual_platform/a55.dtb ${shell_folder}/out/images

	# Pack rootfs
	find . | fakeroot cpio -o -H newc > ${shell_folder}/out/images/rootfs.cpio

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

build_prepare() {
	mkdir -p ${shell_folder}/out/images
	mkdir -p ${shell_folder}/out/rootfs
}

# do some prepare
build_prepare

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
	elif [[ $arg  = "kernel" ]]; then
		build_kernel
	elif [[ $arg  = "rootfs" ]]; then
		build_rootfs
	elif [[ $arg  = "mkimage" ]]; then
		build_mkimage
	elif [[ $arg  = "all" ]]; then
		all_start_time=${SECONDS}
		build_qemu
		build_rootfs
		build_optee
		build_u-boot
		build_atf
		build_mkimage
		build_kernel
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
