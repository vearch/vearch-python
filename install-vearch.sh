#!/bin/bash
set -e -x

# Install a system package required by our library
# yum install -y atlas-devel

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    python_tag=$(echo ${PYBIN} | cut -d '/' -f4)
    "${PYBIN}/pip" uninstall vearch --yes
    "${PYBIN}/pip" install "wheelhouse/vearch-0.3.0.6-${python_tag}-manylinux2010_x86_64.whl"  
     "${PYBIN}/python" -c "import vearch"
done

