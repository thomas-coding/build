#!/bin/bash
#
# Copyright (c) 2024, Thomas
#

export module_save=${module}

mkdir -p ${imagedir}
export intermediate=${intermediate_home}/${module_save}
mkdir -p ${intermediate}
return_code=0

module_home=${module}_home

cd ${build_home}

# We allow build some module without home directory
if [[ -d ${!module_home} ]]; then
    cd ${!module_home}
fi

# Add setup_build at beginning of each module script.
# Move setup into module build script to avoid the env variables
# impacts following modules.
echo "#!/bin/bash" > ${build_home}/.build_${module}.sh
echo "setup_build" >> ${build_home}/.build_${module}.sh

module_script=$(find -L ${build_home} -name build_${module}.sh)
if [[ ${module_script} == "" ]]; then
    echo "Cannot find build script for ${module_save}"
    exit 1
fi
cat ${module_script} >> ${build_home}/.build_${module}.sh || exit 1

chmod +x ${build_home}/.build_${module}.sh

# build
${build_home}/.build_${module}.sh 2>&1 | tee ${logdir}/build_${module_save}.log
pipestatus=${PIPESTATUS[0]}

# remove intermediate directory for clean
if [[ ${build_command} == "clean" && -d ${intermediate} ]]; then
    rm -rf ${intermediate}
fi

# verify source files and do copy for the module
do_verify_copy
if [[ $? != 0 || ${pipestatus} != 0 ]]; then
    return_code=1
    failure_modules+=" ${module_save}"
fi

printf "#### build %s:%s:%s" ${run_context_full} ${product} ${module_save}
if [ ${return_code} = 0 ]; then
    printf " successfully"
else
    printf " failed"
fi
printf " ###\n"


exit ${return_code}
