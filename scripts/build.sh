#! /bin/bash 
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

# functions

function open_file(){
    if [ ! -f $1 ]; then
        echo "File" $1 "not exist."
    fi

    which start
    if [ $? -eq 0 ]; then
        start $1
    else
        which open
        if [ $? -eq 0 ]; then
            open $1
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
    rm -rf _build
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

    # build manual https://pandoc.org/MANUAL.html#extension-empty_paragraphs
    pandoc --from markdown+footnotes --wrap=none --reference-doc=$baseDir/../styles/default.docx -i index.md -o $buildDir/$baseDirname.docx

    if [ ! $? -eq 0 ]; then
        echo "Pandoc exec error"
        exit 3
    fi

    if [ -f $buildDir/$baseDirname.docx ]; then
        echo "File generated in" $buildDir/$baseDirname.docx

        # todo slim build folders
        slim $baseDirname $BACKUP_DIR $KEEPED_BUILDS

        # open file
        open_file $buildDir/$baseDirname.docx
    else
        "Not found" $buildDir/$baseDirname.docx ", build failure."
    fi
}

# main
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return

if [ ! -d $BUILD_ROOT_DIR ]; then
    mkdir $BUILD_ROOT_DIR
fi

if [ ! -d $BACKUP_DIR ]; then
    mkdir $BACKUP_DIR
fi

build $baseDir/..
