#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/config.sh"
. "$DIR/util.sh"

me="`basename $0`"

exec 199>$fallbacklo
if ! flock -xn 199; then
	errcho "[$me] Failed to aquire lock, exiting..." && exit 1
fi

cleanup(){
	if [[ -f $fallbackpidfi ]]; then
		errcho "[$me] Removing Fallback pid file..."
		rm -f $fallbackpidfi
	fi
	errcho "[$me] Removing Fallback lock file..."
	flock -u 199
	flock -xn 199 && rm -f $fallbacklo
}

trap cleanup EXIT

if [[ -f $originpidfi ]]; then
	originpid=$(<$originpidfi)
	errcho "[$me] Stopping online stream (pid $originpid)..."
	rm -f $originpidfi
	kill $originpid
fi

errcho "[$me] Starting offline stream..."
ffmpeg -loglevel warning -i $rtmpi_fallback -c copy -f mpegts pipe:1 > $pfi &
fallbackpid=$!
errcho "[$me] Fallback stream pid $fallbackpid"
echo $fallbackpid > $fallbackpidfi
wait $fallbackpid