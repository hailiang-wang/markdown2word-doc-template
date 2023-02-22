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
export DATE=`date "+%Y%m%d"`
export DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"` #add %3N as we want millisecond too

# functions

# main 
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return

## Avoid Error, https://access.redhat.com/solutions/3168671, fails to change the owner and group of temporary output file
cd $baseDir/
for x in `find . -name '*.sh' -o -name '*.py'`; do
    # echo ">> fix" $x
    dos2unix -q -n $x ${x}.${DATE_WITH_TIME}
    mv ${x}.${DATE_WITH_TIME} $x
done