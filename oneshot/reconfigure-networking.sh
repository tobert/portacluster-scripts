#!/bin/bash
#
# Copyright 2014 Albert P. Tobey <atobey@datastax.com> @AlTobey
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Derived from the installer. Reconfigures nodes in place to use
# a bridge instead of directly using the ethernet interface.

iface=$(ip route show |awk '/^default/{print $5}' |head -n 1)
mac=$(< /sys/class/net/$iface/address)
address=$(ip addr show $iface |awk '/inet /{print $2}')
gateway=$(ip route show |awk '/^default via/{print $3}' |head -n 1)

rm -f /etc/systemd/network/*

# set networking up with bridge br0 by default
cat > /etc/systemd/network/br0.netdev <<EOF
# created by portacluster-scripts/overlay/admin/srv/public/installer/autorun
[NetDev]
Name=br0
Kind=bridge
EOF

# the interface name might change on first boot; match by MAC
cat > /etc/systemd/network/11-eth.network <<EOF
# created by portacluster-scripts/overlay/admin/srv/public/installer/autorun
[Match]
MACAddress=$mac
Name=en*

[Network]
Bridge=br0
EOF

# assign the node address to the bridge
cat > /etc/systemd/network/12-br0.network <<EOF
# created by portacluster-scripts/overlay/admin/srv/public/installer/autorun
[Match]
Name=br0

[Network]
Address=$address
Gateway=$gateway
DNS=192.168.10.10
EOF
