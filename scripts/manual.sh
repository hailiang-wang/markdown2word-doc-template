#! /bin/bash 
###########################################
#
###########################################

# constants
baseDir=$(cd `dirname "$0"`;pwd)
export PYTHONUNBUFFERED=1
export TS=$(date +%Y%m%d%H%M%S)
export PATH=/opt/miniconda3/envs/venv-py3/bin:$PATH
export BACKUP_DIR=$baseDir/../tmp

# functions

# main 
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return
cd $baseDir/..
pwd
set -x
cp README.md MANUAL.md
head -n 2 MANUAL.md > README.md
echo "## Build\n[MANUAL](./MANUAL.md)" >> README.md
