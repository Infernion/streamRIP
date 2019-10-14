#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/config.sh"
. "$DIR/util.sh"

me="`basename $0`"

exec 200>$originlo
if ! flock -xn 200; then
	errcho "[$me] Failed to aquire lock, exiting..." && exit 1
fi

cleanup(){
	if [[ -f $originpidfi ]]; then
		errcho "[$me] Removing Origin pid file..."
		rm -f $originpidfi
	fi
	errcho "[$me] Removing Origin lock file..."
	flock -u 200
	flock -xn 200 && rm -f $originlo
}

trap cleanup EXIT

if [[ -f $fallbackpidfi ]]; then
	fallbackpid=$(<$fallbackpidfi)
	errcho "[$me] Stopping offline stream (pid $fallbackpid)..."
	rm -f $fallbackpidfi
	kill $fallbackpid
fi

errcho "[$me] Starting online stream..."
ffmpeg -loglevel warning -i $rtmpi -c copy -f mpegts pipe:1 > $pfi &
originpid=$!
errcho "[$me] Origin stream pid $originpid"
echo $originpid > $originpidfi
wait $originpid