#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c)
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o errexit
set -o nounset

magma_version=1.3.3

if ! command -v curl; then
    # shellcheck disable=SC1091
    source /etc/os-release || source /usr/lib/os-release
    case ${ID,,} in
        ubuntu|debian)
            sudo apt-get update -qq > /dev/null
            sudo apt-get install -y -qq -o=Dpkg::Use-Pty=0 curl
        ;;
    esac
fi

if ! command -v pip; then
    # NOTE: Shorten link -> https://github.com/electrocucaracha/pkg-mgr_scripts
    curl -fsSL http://bit.ly/install_pkg | PKG=pip PKG_PYTHON_MAJOR_VERSION=2 bash
fi
pip install ansible

pushd "$(mktemp -d)" > /dev/null
curl -o magma.tgz -Ls "https://github.com/magma/magma/archive/v${magma_version}.tar.gz"
mkdir -p ~/magma
tar xf magma.tgz -C ~/magma --strip-components=1
popd > /dev/null

cat << EOF > ~/hosts.ini
[ovs_build]
127.0.0.1 ansible_connection=local

[ovs_deploy]
127.0.0.1 ansible_connection=local
EOF
