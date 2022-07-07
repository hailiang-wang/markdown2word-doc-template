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

if [ ! -d $BACKUP_DIR ]; then
    mkdir $BACKUP_DIR
fi

cd $baseDir/../styles
rm -rf default.md
rm -rf $BACKUP_DIR/default.docx

markup default.m.md -o default.md

if [ ! $? -eq 0 ]; then
    echo "Error"
    exit 1
fi

if [ ! -f default.md ]; then
    echo "Error, md file not found."
    exit 2
fi

pandoc --from markdown+footnotes --wrap=none --reference-doc=./default.docx -i default.md -o $BACKUP_DIR/default.docx

if [ ! $? -eq 0 ]; then
    echo "Error"
    exit 3
fi

if [ ! -f $BACKUP_DIR/default.docx ]; then
    echo "Error, docx file not found."
    exit 2
fi

cp $BACKUP_DIR/default.docx .
echo "Style file generated" `pwd`/default.docx