#! /bin/bash 
###########################################
#
###########################################

# constants
baseDir=$(cd `dirname "$0"`;pwd)
export PYTHONUNBUFFERED=1
export PATH=/opt/miniconda3/envs/venv-py3/bin:$PATH
export TS=$(date +%Y%m%d%H%M%S)
export BACKUP_DIR=$baseDir/../tmp

# functions

# main 
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return
echo "Run hook before execute pandoc cmd ..."
echo "Modify $0 for more process ..."

if [ ! $# -gt 0 ]; then
    echo "Wrong args"
    echo "Usage $0 FILE_PATH"
    exit 1
fi

INPUT_FILE=$1

if [ ! -f $INPUT_FILE ]; then
    echo "File" $INPUT_FILE "not exist."
    exit 2
fi

if [ ! -d $BACKUP_DIR ]; then
    mkdir -p $BACKUP_DIR
fi

echo "Start to process file" $INPUT_FILE "..."
cd $BACKUP_DIR
TMP_FILE=tmp.$TS.md
cp $INPUT_FILE tmp.$TS.md

echo "Copy as temp file" $TMP_FILE "..."

# define your actions, e.g.
# sed -i "s/..\/..\/images\//..\/..\/..\/docfx_project\/images\//g" $TMP_FILE

if [ $? -eq 0 ]; then
    cp $TMP_FILE $INPUT_FILE
else
    echo "Error"
    exit 1
fi