#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/config.sh"
. "$DIR/util.sh"

me="`basename $0`"

# If the working directory doesn't exist already, make it
if [[ ! -d $wd ]]; then
	errcho "[$me] Creating working directory..."
	mkdir $wd
fi

# If the pipe doesn't exist already, make it
if [[ ! -p $pfi ]]; then
	errcho "[$me] Creating pipe file..."
	mkfifo $pfi
fi

# Hold pipe open
sleep infinity >$pfi &
epid=$!

cleanup(){
	errcho "[$me] Removing work directory..."
	rm -rf $wd
	errcho "[$me] Killing $epid..."
	kill $epid
}

trap cleanup EXIT

errcho "[$me] Waiting for stream..."
ffmpeg -loglevel warning \
  -use_wallclock_as_timestamps 1 \
  -f mpegts -i $pfi \
  -r 33 \
  -c:v libx264 \
  -c:a aac \
  -bsf:a aac_adtstoasc \
  -b:v 3M \
  -f flv -rtmp_live live $rtmpe