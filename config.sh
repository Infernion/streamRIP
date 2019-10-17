#!/bin/bash

# The RTMP ingest stream
rtmpi="rtmp://127.0.0.1/live_origin/stream"
# The RTMP fallback stream. Switch to it when main stream has stopped playing
rtmpi_fallback="rtmp://127.0.0.1/live_backup/stream"

# The RTMP output stream
rtmpe="rtmp://127.0.0.1/live_output/stream"


###############
# Don't touch #
###############
wd=/tmp/streamrip
pfi=$wd/streamrip
fallbackpidfi=$wd/offline_pid
originpidfi=$wd/online_pid
fallbacklo=$wd/offline_lock
originlo=$wd/online_lock
