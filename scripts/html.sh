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

    # build html
    # fix image path error
    cd $buildDir
    sed -i "s/(..\/assets\//(assets\//g" index.md
    pandoc --from markdown+footnotes --wrap=none --metadata title="update title in html.sh" --template=$baseDir/../styles/github.html5 -i index.md -o $buildDir/$baseDirname.html
    if [ -f $buildDir/$baseDirname.html ]; then
        if [ ! -d $buildDir/../docs ]; then
            mkdir -p $buildDir/../docs
        fi
        cp $buildDir/$baseDirname.html $buildDir/../docs/index.html
        if [ -d $buildDir/../docs/assets ]; then
            rm -rf $buildDir/../docs/assets
        fi
        cp -rf  $buildDir/../assets $buildDir/../docs/assets
    else
        echo "Generate html failed."
        exit 3
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

$baseDir/autocorrect.sh
build $baseDir/..
