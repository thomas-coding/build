#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

patch_dir=/home/cn1396/workspace/code/x5_qemu/patch

# copy script
cp /home/cn1396/workspace/code/x5_qemu/*.sh ../$1

# patch
# update patch by git diff > build.diff in target dir
patch -d ../$1/atf -p1 < ${patch_dir}/atf.diff
patch -d ../$1/kernel -p1 < ${patch_dir}/kernel.diff
patch -d ../$1/build -p1 < ${patch_dir}/build.diff
patch -d ../$1/uboot -p1 < ${patch_dir}/uboot.diff
