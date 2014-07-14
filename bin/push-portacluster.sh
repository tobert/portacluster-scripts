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

die () {
  echo "$*"
  exit 1
}

[ -n "$USER" ] || die "USER envvar must be set to your remote username"

bindir=$(dirname $0)
dir=$(cd $bindir/.. && pwd)
remote_dir="/home/$USER/portacluster-scripts"

~/bin/cl-rsync.pl --list portacluster --delete -l $dir/./ -r $remote_dir

# vim: ft=sh ts=2 sw=2 noet tw=120 softtabstop=2
