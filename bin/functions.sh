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

export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# node0 should always have Squid running on 3128
# pacman, wget, curl, and many other tools will automatically use this
export http_proxy="node0.pc.datastax.com:3128"

die () {
  echo "$*"
  exit 1
}

pkg_installed () {
  pacman -Q $1 >/dev/null 2>&1
  return $?
}

pkg_install () {
  pacman -S --noconfirm --needed $*
}

pkg_update () {
  pacman -Sy --noconfirm
}

pkg_update () {
  pacman -S -cc --noconfirm
}

require () {
  file=$1
  if [ ! -e "$file" ] ; then
    echo "'$file' does not exist. Exiting with status 9 (keep going)."
    exit 9
  fi
}

this_is_admin () { require /etc/portacluster/is-admin-node; }
this_is_worker () { require /etc/portacluster/is-worker-node; }
this_is_sparta () { kill -9 1; }

# vim: ft=sh ts=2 sw=2 noet tw=120 softtabstop=2
