#!/bin/sh
# @file boost.sh
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

BOOST_URL='http://sourceforge.net/projects/boost/files/boost/1.51.0/boost_1_51_0.tar.bz2/download'
BOOST_TARBALL=boost.tar.bz2

cd "$DIR" || fatal "Cannot cd into $DIR"

[ ! -f "$BOOST_TARBALL" ] && wget "$BOOST_URL" -O "$BOOST_TARBALL"

if [ ! -d BOOST ]
then
	mkdir BOOST
	tar xvf "$BOOST_TARBALL" -C BOOST
fi

cd BOOST/*

[ ! -f b2 ] && ./bootstrap.sh --prefix="$PREFIX"

CONFIG_FILE=user-config.jam
cat > "$CONFIG_FILE" << EOF
using gcc
	:
	: g++-4.7
	: <cxxflags>-std=c++11
	;

using python
	: 3.3
	: $PREFIX/bin/python3
	: $PREFIX/include/python3.3m
	;
EOF

[ -z "$COMPONENTS" ] && COMPONENTS="system filesystem signals thread python test"
[ -z "$VARIANT" ] && VARIANT=release
[ -z "$LINK" ] && LINK=shared
[ -z "$THREADING" ] && THREADING=multi

CMD=

for component in $COMPONENTS
do
	CMD="$CMD --with-$component"
done

./b2 --prefix="$PREFIX" --user-config=user-config.jam $CMD variant=$VARIANT link=$LINK threading=$THREADING python=3.3 install

