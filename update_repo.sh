#!/bin/bash -x

# update_repo.sh
# Script to take downloaded workspace from EDAPlayground and copy files into this repo

RESULTS=~/Downloads/result.zip
REPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cp $RESULTS $REPO
unzip -u -o $REPO/result.zip
rm $REPO/result.zip
