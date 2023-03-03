#! /bin/bash 
###########################################
#
###########################################

# constants
baseDir=$(cd `dirname "$0"`;pwd)
cwdDir=$PWD
export PYTHONUNBUFFERED=1
export PATH=/opt/miniconda3/envs/venv-py3/bin:$PATH
export TS=$(date +%Y%m%d%H%M%S)
export DATE=`date "+%Y-%m-%d"`
export DATE_WITH_TIME=`date "+%y%m%d_%H%M"` #add %3N as we want millisecond too
export PARTIALS_DIR=$baseDir/../partials

# functions

function printUsage(){
    echo "$0 file name"
    echo "    e.g. $0 FOO BAR"
}

function create(){

cat >$1 <<EOF
---
date: ${DATE}
mindmap-plugin: basic
tags: ["foo"]
page-title: ""
url: 
---



EOF

}

# main 
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return

if [ $# -eq 0 ]; then
    printUsage
    exit 1
fi

cd $baseDir/..

if [ ! -e $PARTIALS_DIR ]; then
    mkdir $PARTIALS_DIR
fi

PARTIAL_FILENAME=$DATE_WITH_TIME

if [ $# -gt 0 ]; then
    PARTIAL_FILENAME=${PARTIAL_FILENAME}_$*
fi

PARTIAL_FILENAME="${PARTIAL_FILENAME// /_}"

echo "$PARTIAL_FILENAME"

PARTIAL_FILEPATH=$PARTIALS_DIR/${PARTIAL_FILENAME}.m.md

if [ -f $PARTIAL_FILEPATH ]; then
    echo "File" $PARTIAL_FILEPATH "exist."
    exit
fi

create $PARTIAL_FILEPATH

if [ $? -eq 0 ]; then
    echo "Created" $PARTIAL_FILEPATH
else
    echo "Error"
    exit 1
fi

