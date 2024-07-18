#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

#$1: option name
#$2: export variable name
function get_option()
{
    local option=$1
    local variable=$2

    if [[ ${module} == "unittest" ]]; then
        module_option="${module_save}_${option}"
    else
        module_option="${module}_${option}"
    fi

    if [[ -n ${!module_option+x} ]]; then
        eval "export ${variable}=${!module_option}"
    elif [[ -n ${!option+x} ]]; then
        eval "export ${variable}=${!option}"
    fi
}
export -f get_option

function setup_build()
{
    # local toolchain path
    rm -rf ${local_toolchain_path}
    mkdir -p ${local_toolchain_path}/bin

    # toolchain
    setup_toolchain ${toolchain}

    # CROSS_COMPILE
    get_option cross_compile CROSS_COMPILE
    echo "CROSS_COMPILE: ${CROSS_COMPILE}"

    # ARCH
    get_option arch ARCH
    echo "ARCH=${ARCH}"
}
export -f setup_build
