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

source "$(dirname $0)/../bin/functions.sh"

if this_is_worker ; then

	mkdir -p /srv/cassandra

	(grep -q '^cassandra:' /etc/group)  || groupadd -g 1234 cassandra
	(grep -q '^cassandra:' /etc/passwd) || useradd -u 1234 -c "Apache Cassandra" -g cassandra -s /bin/bash -d /srv/cassandra

	chown -R cassandra:cassandra /srv/cassandra
fi

# vim: ft=sh ts=2 sw=2 noet tw=120 softtabstop=2
