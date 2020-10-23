#!/bin/bash
set -e -x

# Install a system package required by our library
# yum install -y atlas-devel

# Compile wheels


OS=`uname -s`
if [ ${OS} == "Darwin" ];then
    for WHEEL in ./dist/fixed_wheels/vearch* 
    do
        TAG_NUM=`echo ${WHEEL} | grep -Eo "cp[0-9]{2}" | sed -n "1p"`
        TAG=${TAG_NUM:2:1}.${TAG_NUM:3}
        PY_NAME=python${TAG}
        conda create -n ${PY_NAME} python=${TAG}  --y
        source activate
        conda activate ${PY_NAME}
        pip uninstall vearch --y
        pip install ${WHEEL}
    done            
elif [ `expr substr ${OS} 1 5` == "Linux" ];then
    for PYBIN in /opt/python/*/bin; do
        python_tag=$(echo ${PYBIN} | cut -d '/' -f4)
        "${PYBIN}/pip" uninstall vearch --yes
        "${PYBIN}/pip" install "wheelhouse/vearch-0.3.0.6-${python_tag}-manylinux2010_x86_64.whl"  
         "${PYBIN}/python" -c "import vearch"
    done
elif [];then
    echo "Windows not support!!!"
fi

