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

source "$(dirname $0)/functions.sh"

sh="/bin/bash"
bindir=$(dirname $0)
dir=$(cd $bindir/.. && pwd)
cache="/var/cache/portacluster-scripts"
runtime=$(date --iso-8601=seconds)
logfile="$cache/log/$runtime"

sudo /bin/bash --version > /dev/null || die "this script requires sudo permissions"
[ -d $cache ] || sudo mkdir -p $cache
[ -d $cache/log ] || sudo mkdir -p $cache/log

sudo touch $logfile
sudo chown $USER $logfile

echo "tail -f $logfile # to watch the logfile in another terminal"

log () {
  if [ -n "$VERBOSE" ] ; then
    echo "$*"
  fi

  if [ -r $logfile ] ; then
    echo "$*" >> $logfile
  else
    logger "$*"
  fi
}

to_console () {
  pos=$1
  len=$(wc -l $logfile |awk '{print $1}')
  tail -n $(($len - $pos)) $logfile
}

run () {
  log_position=$(wc -l $logfile |awk '{print $1}')
  log "Running: 'sudo $*'"
  sudo -H $* 2>&1 >> $logfile
  ret=$?

  if [ $ret -ne 0 -a $ret -ne 9 ] ; then
    log "$* failed with error: '$ret'"
    echo "failed"
    to_console $log_position
    exit 1
  else
    log "$* succeeded."
  fi

  echo >> $logfile
}

push_overlay () {
	overlay=$1
	if [ -d $dir/overlay/$overlay ] ; then
		cd $dir/overlay/$overlay
		# sudoers must never be copied from the files dir ; the permissions go bad
		# and everything from here on fails - check out scripts.d/05-sudo.sh
		rsync_command="rsync -av --exclude etc/sudoers $dir/overlay/$overlay/./ /"
		echo "rsyncing files directory over system ($rsync_command) ..."
		run $rsync_command 2>&1 >> $logfile
	else
		echo "overlay '$overlay' not found"
		return 1
	fi

	# this is risky+effective: produce a list of files in the overlay
	# directory, remove the local prefix, then chown all those files to
	# be owned by root:root so they don't show up as owned by a user
	echo "chowning rsynced files to root:root ..."
	src="$dir/overlay/$overlay"
	find "$src" |sed "s#$src##" |sudo xargs chown root:root >> $logfile
}

echo "Updating sudo configuration."
run $sh $dir/scripts.d/01-sudo.sh

# rsync overlays onto the system
push_overlay all

if this_is_admin ; then
	push_overlay admin
elif this_is_worker ; then
	push_overlay worker
fi

# run through the scripts in scripts.d, mark them complete by touching a
# file based on the sha256 checksum of the script so they only get run
# when they change
cd $dir
for script in $dir/scripts.d/*
do
  id=$(sha256sum $script |awk '{print $1}')
  idfile="/var/cache/portacluster-scripts/$id"
  if [ ! -e $idfile ] ; then
    echo -n "Running: $sh -x $script ..."
    run $sh -x $script 2>&1 >> $logfile
    # returning 9 is fairly uncommon, if scripts.d scripts return 9 that means they didn't
    # run on purpose and this script should continue
    if [ $? -eq 0 ] ; then
      echo " success!"
      run touch $idfile
    fi
  else
    log "Already ran this version of $script ($id)"
  fi
done

# vim: ft=sh ts=2 sw=2 noet tw=120 softtabstop=2
