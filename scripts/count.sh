#! /bin/bash 
###########################################
# 统计文本字数，包括二级标题和总和
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

function work(){
    cd $1
    rootDir=`pwd`
    sourcesDir=`pwd`/sources

    echo ">> sourcesDir" $sourcesDir

    cd $sourcesDir
    if [ ! -f index.m.md ]; then
        echo "File index.m.md not exists in" $sourcesDir
        exit 1
    fi

    if [ -f index.md ]; then
        echo "File index.md should not exists in" $sourcesDir
        exit 1
    fi

    baseDirname=`basename -- $rootDir`
    echo ">> baseDirname" $baseDirname

    cd $baseDir/..
    if [ -f _build/index.md ]; then
        cp -rf _build $BACKUP_DIR/$baseDirname.$TS
    fi

    cd $baseDir/..
    if [ -d _build ]; then
        rm -rf _build
        if [ ! $? -eq 0 ]; then
            echo "Remove old build dir failure."
            exit 1
        fi
    fi

    cp -rf sources _build
    buildDir=$baseDir/../_build
    echo ">> buildDir" $buildDir

    cd $buildDir
    markup index.m.md -o index.md
    
    if [ ! $? -eq 0 ]; then
        echo "Build error"
        exit 2
    fi

    if [ ! -f index.md ]; then
        echo "Not found index.md in" $buildDir
        exit 1
    fi

    echo ">> index.md generated -->" `pwd`/index.md
    export MD_INDEX_FILEPATH=`pwd`/index.md
    python3 $baseDir/py/count_words.py
}

# main 
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return
$baseDir/fix_dos2unix.sh

## Resolve machine
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

if [ ! -d $BUILD_ROOT_DIR ]; then
    mkdir $BUILD_ROOT_DIR
fi

if [ ! -d $BACKUP_DIR ]; then
    mkdir $BACKUP_DIR
fi

$baseDir/autocorrect.sh
work $baseDir/..
