#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

function usage()
{
    echo "./build.sh <option> <product>"
    echo "    --clean:                Clean the product"
    echo "    -h|--help:              Show this help information"
}

setup_start_time=${SECONDS}

# default environment
build_command=""
enable_module_alias=""
product=""
saved_arg="$*"
saved_option=""
saved_assign=""

for arg in "$@"; do
    arg=$1
    case $arg in
        -h | --help)
            usage
            exit 0
            ;;
        *=*)
            saved_option+=" ${arg}"
            shift
            ;;
        *)
            if [[ ${product} == "" ]]; then
                export product=${arg}
            else
                saved_modules+=" ${arg}"
            fi
            shift
            ;;
    esac
done

# Install utilities
for file in utility/*.sh; do
    . ${file}
done

# load global config
. config/global_config

# load product config
. config/product_config

function init_module()
{


    # module alias
    if [[ ${saved_modules} != "" ]]; then
        # "all" module
        saved_modules=${saved_modules//all/${modules}}
        modules=${saved_modules}
    fi

}

# prepare for buildling
init_module

mkdir -p ${logdir}
mkdir -p ${imagedir}
mkdir -p ${toolchain_path}
rm -rf ${out}/copy_list

# prepare for buildling
#pre_build

setup_finish_time=${SECONDS}
setup_duration=$((setup_finish_time - setup_start_time))

build_duration=0
elapsed_time_report=""
failure_module=""
return_code=0

echo "modules: ${modules}"
for module in ${modules}; do

    start_time=${SECONDS}

    export module=${module}

    # export variable to pass to build script
    export saved_option=${saved_option}

    # run build module in separated bash to
    # avoid one module environment impacts another one
    ./script/build_module.sh
    return_code=$?

    finish_time=${SECONDS}
    duration=$((finish_time - start_time))
    build_duration=$((build_duration + duration))
    elapsed_time="$((duration / 60))m $((duration % 60))s"
    elapsed_time_report+="${module}: ${elapsed_time}\n"

    if [[ ${return_code} != 0 ]]; then
        failure_module="${module}"
        break
    fi
done

setup_time="$((setup_duration / 60))m $((setup_duration % 60))s"
build_time="$((build_duration / 60))m $((build_duration % 60))s"

total_duration=$((setup_duration + build_duration))
total_time="$((total_duration / 60))m $((total_duration % 60))s"

elapsed_time_report+="-----------------------------\n"
elapsed_time_report+="total build time: ${build_time}\n"
elapsed_time_report+="setup time: ${setup_time}\n"
elapsed_time_report+="total time: ${total_time}\n"

if [[ ${disable_build_summary} != 1 ]]; then
    echo "build elapsed time:"
    echo -e "${elapsed_time_report}"
fi

if [ ${return_code} = 0 ]; then
    if [[ ${disable_build_summary} != 1 ]]; then
        echo "The build is successfully done for ${product}"
    fi
    if [[ ${run_context} == "cros_sdk" ]]; then
        echo "${return_code}" > ${cros_build_pass}
    fi
else
    if [[ ${disable_build_summary} != 1 ]]; then
        echo "The build is failed for ${product} in this module:${failure_module}"
    fi
    rm -rf ${cros_build_pass}
fi

rm -rf ${build_home}/.build*.sh

# post process after building
#post_build

exit ${return_code}

