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
cd $baseDir/../styles
markup default.m.md -o default.md

if [ ! $? -eq 0 ]; then
    echo "Error"
    exit 1
fi

if [ ! -f default.md ]; then
    echo "Error, md file not found."
    exit 2
fi

pandoc --from markdown+footnotes --wrap=none --reference-doc=./default.docx -i default.md -o default.docx

if [ ! $? -eq 0 ]; then
    echo "Error"
    exit 3
fi

if [ ! -f default.docx ]; then
    echo "Error, docx file not found."
    exit 2
fi


echo "Style file generated" `pwd`/default.docx