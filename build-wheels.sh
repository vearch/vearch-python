#!/bin/bash
set -e -x

# Install a system package required by our library
# yum install -y atlas-devel

BASE_PATH=`pwd`
OS=`uname -s`
cp -r $BASE_PATH/gamma/idl/fbs-gen/python/* $BASE_PATH/python

if [ ${OS} == "Darwin" ];then
    export GAMMA_LDFLAGS=$BASE_PATH/gamma/build/libgamma.dylib
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
    export GAMMA_LDFLAGS=$BASE_PATH/gamma/build/libgamma.so
    for PYBIN in /opt/python/*/bin; do
        "${PYBIN}/pip" install -r dev-requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
        "${PYBIN}/python" setup.py bdist_wheel
        auditwheel repair dist/vearch* 
        rm -rf dist 
    done 
elif [ `expr substr ${OS} 1 10` == "MINGW" ];then  
    echo "windows not support"
fi


