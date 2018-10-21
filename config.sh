#!/usr/bin/env bash

#  config.sh
#  Created by Mohamed taieb on 17/09/2018.

set -e

export LC_ALL=en_US.UTF-8
export TERM=xterm
export PATH=/usr/local/bin:$PATH

export FORMAT_BOLD=$(tput bold)
export FORMAT_NORMAL=$(tput sgr0)
export PWD=$(pwd)

log() { echo "$(date "+%Y-%m-%d %H:%M:%S") ($(basename "$0")) $1"; }
