#!/bin/sh
# @file python.sh
# @author <raphael.londeix@gmail.com> Raphael Londeix
# @version @FIXME@

SCRIPTCMD="$0"
SCRIPT=`basename "$0"`
SCRIPT_DIR=`python -c "import os;print(os.path.abspath(os.path.dirname('$0')))"`

abspath()
{
	echo `python3 -c "import os;print(os.path.abspath('$1'))"`
}

fatal()
{
	echo "$*" 2>&1
	exit 1
}

usage()
{
	fatal "Usage: $SCRIPTCMD build_dir install_dir"
}

[ -z "$1" ] && usage
[ -z "$2" ] && usage

DIR=`abspath "$1"`
PREFIX=`abspath "$2"`

[ ! -d "$PREFIX" ] && fatal "$PREFIX is not a directory"

mkdir -p "$DIR" || fatal "Cannot create $DIR directory"

PYTHON_URL="http://www.python.org/ftp/python/3.3.0/Python-3.3.0.tar.bz2"
PYTHON_TARBALL=python.tar.bz2

cd "$DIR" || fatal "Cannot cd into $DIR"

[ ! -f "$PYTHON_TARBALL" ] && wget "$PYTHON_URL" -O "$PYTHON_TARBALL"


if [ ! -d PYTHON ]
then
	mkdir PYTHON
	tar xvf "$PYTHON_TARBALL" -C PYTHON
fi

cd PYTHON/*

./configure --prefix="$PREFIX" && make && make install

