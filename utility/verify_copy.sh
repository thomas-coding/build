#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

function do_verify_copy()
{
    # no copy to do
    if [ ! -f ${out}/copy_list ]; then
        return 0
    fi

    local return_code=0

    all_list=$(cat ${out}/copy_list)

    src_file=

    for item in ${all_list}; do
        if [[ ${src_file} == "" ]]; then
            src_file=${item}
            src_file=${src_file//\"/}

            # shellcheck disable=SC2012
            count=$(ls -l ${src_file} 2> /dev/null | wc -l)
            if [[ ${count} == 0 ]]; then
                echo "Error: source file missed: ${src_file}"
                return_code=1
            fi
        else
            if ! cp -r -p -d ${src_file} ${item}; then
                return_code=1
            fi

            # reset source file for next copy
            src_file=
        fi
    done

    # clear copy list
    rm -rf ${out}/copy_list

    return ${return_code}
}
export -f do_verify_copy

function do_rm()
{
    src_file=$1

    src_file=${src_file//\"/}
    rm -rf ${src_file}
}
export -f do_rm

#$1: source file
#$2: destination file or folder
function _add_target()
{
    echo "$1 $2" >> ${out}/copy_list
}
export -f _add_target

#$1: source file
#$2: destination file or folder
function add_target()
{
    _add_target $1 $2
    do_rm $1
}
export -f add_target

#$1: source file
#$2: destination file or folder
function add_target2()
{
    _add_target $1 $2
}
export -f add_target2

#$1: source file
#$2: destination folder
function _add_target_to_folder()
{
    if [[ ! -d $2 ]]; then
        mkdir -p $2
    fi

    _add_target $1 $2
}
export -f _add_target_to_folder

#$1: source file
#$2: destination folder
function add_target_to_folder()
{
    _add_target_to_folder $1 $2
    do_rm $1
}
export -f add_target_to_folder

#$1: source file
#$2: destination folder
function add_target_to_folder2()
{
    _add_target_to_folder $1 $2
}
export -f add_target_to_folder2

function add_target_bin()
{
    add_target_to_folder $1 ${target_bin_dir}
}
export -f add_target_bin

function add_target_bin2()
{
    add_target_to_folder2 $1 ${target_bin_dir}
}
export -f add_target_bin2

function add_target_lib()
{
    add_target_to_folder $1 ${target_lib_dir}
}
export -f add_target_lib

function add_target_lib2()
{
    add_target_to_folder2 $1 ${target_lib_dir}
}
export -f add_target_lib2

function add_target_vendor_bin()
{
    add_target_to_folder $1 ${target_vendor_bin_dir}
}
export -f add_target_vendor_bin

function add_target_vendor_bin2()
{
    add_target_to_folder2 $1 ${target_vendor_bin_dir}
}
export -f add_target_vendor_bin2

function add_target_vendor_lib()
{
    add_target_to_folder $1 ${target_vendor_lib_dir}
}
export -f add_target_vendor_lib

function add_target_vendor_lib2()
{
    add_target_to_folder2 $1 ${target_vendor_lib_dir}
}
export -f add_target_vendor_lib2

function add_target_firmware()
{
    add_target_to_folder $1 ${target_firmware_dir}
}
export -f add_target_firmware

#$1: source file
#$2: destination file
function copy_if_diff()
{
    if ! diff $1 $2 >&/dev/null; then
        cp $1 $2
    fi
}
export -f copy_if_diff
