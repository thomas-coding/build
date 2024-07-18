#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

#$1: toolchain name
function install_toolchain()
{
    local toolchain_name=$1
    local all_suffix=".tar.gz .tar.xz .bz2 .tar.bz2 -linux.tar.bz2 -x86_64-linux.tar.bz2 .zip"

    # skip if the toolchain exist
    if [[ -d ${toolchain_path}/${toolchain_name} ]]; then
        return
    fi

    for suffix in ${all_suffix}; do
        rm -rf ${toolchain_name}${suffix}
        wget -q ${toolchain_URL}/${toolchain_name}${suffix}

        if [[ $? == 0 && -f ${toolchain_name}${suffix} ]]; then
            local tmpdir=$(mktemp -d)
            if [[ ${suffix} == ".zip" ]]; then
                unzip -q ${toolchain_name}${suffix} -d ${tmpdir}
            else
                tar xf ${toolchain_name}${suffix} -C ${tmpdir}
            fi
            result=$?
            if [[ ${result} == 0 ]]; then
                if [[ -d ${tmpdir}/${toolchain_name} ]]; then
                    mv ${tmpdir}/${toolchain_name} ${toolchain_path}
                else
                    # There should be only one folder in toolchain package
                    mv ${tmpdir}/* ${toolchain_path}/${toolchain_name}
                fi
            else
                exit 1
            fi
            rm ${toolchain_name}${suffix}
            return
        fi
    done

    echo "toolchain cannot be found on server: ${toolchain_name}"

    exit 1
}
export -f install_toolchain

#$1..$#: toolchain list
function setup_toolchain()
{
    local current_toolchain_path
    module_toolchain=${module}_toolchain

    current_toolchain="$*"
    current_toolchain_subpath=${toolchain_subpath}
    if [[ ${!module_toolchain} != "" ]]; then
        current_toolchain="${current_toolchain} ${!module_toolchain}"
        module_toolchain_subpath=${module}_toolchain_subpath
        current_toolchain_subpath+=" ${!module_toolchain_subpath}"
    fi

    export PATH=${DEFAULT_PATH}
    current_toolchain_subpath="bin ${current_toolchain_subpath}"

    for toolchain in ${current_toolchain}; do
        install_toolchain ${toolchain}
        
        for subpath in ${current_toolchain_subpath}; do
            current_toolchain_path=${toolchain_path}/${toolchain}/${subpath}
            if [[ -d ${current_toolchain_path} ]]; then
                export PATH=${current_toolchain_path}:$PATH
            fi
        done
    done
}
export -f setup_toolchain
