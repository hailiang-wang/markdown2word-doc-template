#! /bin/bash 
###########################################
#
###########################################

# constants
baseDir=$(cd `dirname "$0"`;pwd)
export PYTHONUNBUFFERED=1
export PATH=/opt/miniconda3/envs/venv-py3/bin:$PATH

# functions

# main 
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return
CMD="PLACEHOLDER"

# if []; then

# fi

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac
echo ${MACHINE}

if [ $MACHINE == "MinGw" ]; then
    CMD=$baseDir/autocorrect/win
elif [ $MACHINE == "Darwin" ]; then
    CMD=$baseDir/autocorrect/macos
    chmod +x $CMD
elif [ $MACHINE == "Cygwin" ]; then
    CMD=$baseDir/autocorrect/win
elif [ $MACHINE == "Linux" ]; then
    CMD=$baseDir/autocorrect/linux
    chmod +x $CMD
else
    echo "Not supported" $MACHINE
    exit 1
fi

cd $baseDir/..

$CMD --fix sources