#!/bin/bash

ROOT_PATH=`pwd`
BASE_PATH=$ROOT_PATH"/gamma"
OS=`uname -s`
cp -r $BASE_PATH/idl/fbs-gen/python/* ./python

if [ ${OS} == "Darwin" ];then
    export GAMMA_LDFLAGS=$BASE_PATH/build/libgamma.dylib
    PY_TAGS=(2.7 3.6 3.7 3.8 3.9)
    for TAG in ${PY_TAGS[*]} 
    do
        PY_NAME=python${TAG}
        conda create -n ${PY_NAME} python=${TAG}  --y
        source activate
        conda activate ${PY_NAME}
        pip install -r dev-requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
        if [ $TAG == "2.7" ];then
            export MACOSX_DEPLOYMENT_TARGET=`sw_vers | grep ProductVersion | awk '{print $2}'`
        fi
        python setup.py bdist_wheel
    done
elif [ `expr substr ${OS} 1 5` == "Linux" ];then
    #Compile wheels
    export GAMMA_LDFLAGS=$BASE_PATH/build/libgamma.so
    export GAMMA_INCLUDE=$BASE_PATH
    export LD_LIBRARY_PATH=$BASE_PATH/build/:$LD_LIBRARY_PATH
    for PYBIN in /opt/python/*/bin; do
        if [[ ${PYBIN} =~ "cp" ]]; then
            "${PYBIN}/pip" install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
            "${PYBIN}/python" setup.py bdist_wheel
            auditwheel repair dist/vearch* 
            rm -rf dist build vearch.egg-info 
        fi
    done 
elif [ `expr substr ${OS} 1 10` == "MINGW" ];then  
    echo "windows not support"
fi


