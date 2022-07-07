#! /bin/bash
###########################################
#
# https://github.com/huacnlee/autocorrect
###########################################

# constants
baseDir=$(cd `dirname "$0"`;pwd)
export PYTHONUNBUFFERED=1
export PATH=/opt/miniconda3/envs/venv-py3/bin:$PATH
MACHINE=

# functions

# main
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return
CMD="PLACEHOLDER"

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

if [ $MACHINE == "MinGw" ]; then
    CMD=$baseDir/formatters/autocorrect_win
elif [ $MACHINE == "Darwin" ]; then
    CMD=$baseDir/formatters/autocorrect_macos
    chmod +x $CMD
elif [ $MACHINE == "Cygwin" ]; then
    CMD=$baseDir/formatters/autocorrect_win
elif [ $MACHINE == "Linux" ]; then
    CMD=$baseDir/formatters/autocorrect_linux
    chmod +x $CMD
else
    echo "Not supported" $MACHINE
    exit 1
fi

cd $baseDir/../sources

for x in `find . -name "*.md"`; do
    echo "merge_chinese_chars in sources <<" $x
    echo "force_endof_blank in sources <<" $x
    if [ $MACHINE == "Cygwin" ]; then
        python `cygpath -w $baseDir/formatters/merge_chinese_chars.py` $x
        python `cygpath -w $baseDir/formatters/force_endof_blank.py` $x
    else
        $baseDir/formatters/merge_chinese_chars.py $x
        $baseDir/formatters/force_endof_blank.py $x
    fi
done

set -x
cd $baseDir/..
$CMD --fix sources