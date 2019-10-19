#!/bin/bash

errcho(){ >&2 echo $@; }

# Output to log file
exec 1>>/tmp/streamrip/streamRIP.log
exec 2>&1
