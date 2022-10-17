#! /bin/bash
shopt -s expand_aliases
###########################################
#
###########################################

# constants
baseDir=$(cd `dirname "$0"`;pwd)
export TS=$(date +%Y%m%d%H%M%S)
export PYTHONUNBUFFERED=1
export PATH=/opt/miniconda3/envs/venv-py3/bin:$PATH
export BUILD_ROOT_DIR=$baseDir/../_build
export BACKUP_DIR=$baseDir/../tmp
export KEEPED_BUILDS=10
MACHINE=

# functions

function open_file(){
    if [ ! -f $1 ]; then
        echo "File" $1 "not exist."
    fi

    if [ -n "$IS_WSL" ] || [ -n "$WSL_DISTRO_NAME" ]; then
        # Fix the /mnt path prefix problem
        #     https://learn.microsoft.com/en-us/windows/wsl/filesystems
        #     https://superuser.com/questions/1633603/is-it-possible-to-open-windows-applications-from-inside-a-windows-subsystem-for
        targetDir=$(cd `dirname "$1"`;pwd)
        cd $targetDir
        cmd.exe /c start `filename $1`
    else
        command -v start &> /dev/null
        if [ $? -eq 0 ]; then
            start $1
        else
            command -v open &> /dev/null
            if [ $? -eq 0 ]; then
                open $1
            else
                command -v start.sh &> /dev/null
                if [ $? -eq 0 ]; then
                    start.sh $1
                fi
            fi
        fi
    fi
}

function slim(){
	prefix=$1
	builds_dir=$2
	keeped=$3
	# echo "slim<<Process prefix $prefix in $builds_dir, only keep latest $keeped versions ..."

	cd $builds_dir
	versions=`ls -dtr $prefix.*`
	arr=($(echo "$versions" | tr '\n' '\n'))
	arrSize=${#arr[@]}
	# echo "slim>>$prefix#build versions size" $arrSize
	if [[ $arrSize -gt $keeped ]]; then
	   echo "slim>>$prefix#remove old builds ..."
	   for x in ${arr[@]:0:`expr $arrSize-$keeped`}; do
		#echo "$prefix#deleting dir " `pwd`/$x "..."
		rm -rf $x
	   done
	else
	   echo "slim>>$prefix#skip deletion old builds."
	fi
}


function build(){
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

    # tune index.md before convert into Word with pandoc.
    if [ -f $baseDir/hook.before_pandoc.sh ]; then
        $baseDir/hook.before_pandoc.sh $buildDir/index.md
    fi

    # build manual https://pandoc.org/MANUAL.html#extension-empty_paragraphs
    set -x
    if [ $MACHINE == "Cygwin" ]; then
        STYLE_FILE=`cygpath -w $baseDir/../styles/default.docx`
        OUTPUT_DOCX=`cygpath -w $buildDir/$baseDirname.docx`
        pandoc --from markdown+footnotes --wrap=none --reference-doc=$STYLE_FILE -i index.md -o $OUTPUT_DOCX
    else
        pandoc --from markdown+footnotes --wrap=none --reference-doc=$baseDir/../styles/default.docx -i index.md -o $buildDir/$baseDirname.docx
    fi
    set +x

    if [ ! $? -eq 0 ]; then
        echo "Pandoc exec error"
        exit 3
    fi

    if [ -f $buildDir/$baseDirname.docx ]; then
        echo "File generated in" $buildDir/$baseDirname.docx

        # todo slim build folders
        slim $baseDirname $BACKUP_DIR $KEEPED_BUILDS
        echo "x"
        # open file
        echo "Open File" $buildDir/$baseDirname.docx
        open_file $buildDir/$baseDirname.docx
    else
        "Not found" $buildDir/$baseDirname.docx ", build failure."
    fi
}

# main
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return

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
build $baseDir/..
