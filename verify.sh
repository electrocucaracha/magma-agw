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

#/usr/sbin/service magma@* status

for svc in control_proxy directoryd dnsd enodebd magmad mme mobilityd pipelined policydb redis sctpd sessiond state subscriberdb; do
    if ! systemctl is-active --quiet "magma@$svc"; then
        echo "Magma $svc is not running"
    fi
done

for pkg in magma magma-cpp-redis magma-libfluid oai-gtp libopenvswitch openvswitch-datapath-dkms openvswitch-datapath-source openvswitch-common openvswitch-switch; do
    if ! dpkg -l $pkg &> /dev/null; then
        echo "$pkg hasn't been installed"
    fi
done
