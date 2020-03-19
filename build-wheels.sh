#!/bin/bash
set -e -x

# Install a system package required by our library
# yum install -y atlas-devel

export GAMMA_LDFLAGS='-lgamma'

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install -r dev-requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
    "${PYBIN}/python" setup.py bdist_wheel
    auditwheel repair dist/vearch* 
    rm -rf dist 
done

