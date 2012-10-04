#!/bin/sh
# @file gcc47.sh
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
	fatal "Usage: $SCRIPTCMD build_dir prefix"
}

[ -z "$1" ] && usage
[ -z "$2" ] && usage

PROJECT_DIR=`abspath "$1"`
PREFIX=`abspath "$2"`

[ ! -d "$PREFIX" ] && fatal "Install prefix '$PREFIX' does not exist"

GCC_URL="http://www.netgull.com/gcc/releases/gcc-4.7.2/gcc-4.7.2.tar.bz2"
GCC_TARBALL="gcc.tar.bz2"
GCC_CONFIGURE='"${SRC_DIR}"/configure --prefix="$PREFIX" --with-gmp="$PREFIX" --with-mpfr="$PREFIX" --with-mpc="$PREFIX" --program-suffix=-4.7 --enable-cloog-backend=isl --with-ppl="$PREFIX" --with-cloog="$PREFIX"'

PPL_URL="http://bugseng.com/external/ppl/download/ftp/releases/0.12/ppl-0.12.tar.bz2"
PPL_TARBALL="ppl.tar.gz"
PPL_CONFIGURE='"${SRC_DIR}"/configure --prefix="$PREFIX" --with-gmp="$PREFIX"'

CLOOG_URL="http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.16.1.tar.gz"
CLOOG_TARBALL="cloog.tar.gz"
CLOOG_CONFIGURE='"${SRC_DIR}"/configure --prefix="$PREFIX" --with-gmp-prefix="$PREFIX"'

MPC_URL="http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz"
MPC_TARBALL="mpc.tar.gz"
MPC_CONFIGURE='"${SRC_DIR}"/configure --prefix="$PREFIX" --with-gmp="$PREFIX" --with-mpfr="$PREFIX"'

GMP_URL="ftp://ftp.gmplib.org/pub/gmp-5.0.5/gmp-5.0.5.tar.bz2"
GMP_TARBALL="gmp.tar.bz2"
GMP_CONFIGURE='"${SRC_DIR}"/configure --prefix="${PREFIX}" --enable-cxx'

MPFR_URL="http://mpfr.loria.fr/mpfr-current/mpfr-3.1.1.tar.bz2"
MPFR_TARBALL="mpfr.tar.bz2"
MPFR_CONFIGURE='"${SRC_DIR}"/configure --prefix="$PREFIX" --with-gmp="$PREFIX"'


mkdir -p "$PROJECT_DIR" || fatal "Cannot create gcc directory"

cd "$PROJECT_DIR"

COMPONENTS="GCC PPL CLOOG MPC GMP MPFR"

for component in ${COMPONENTS}
do
	eval tarball=\${${component}_TARBALL}
	eval url=\${${component}_URL}
	[ ! -f "$tarball" ] && wget "${url}" -O "${tarball}"
	[ ! -d "$component" ] && mkdir "$component" && tar xvf "${tarball}" -C "${component}"
done

# order is important
#COMPONENTS_BUILD="GMP MPFR MPC PPL CLOOG GCC"
COMPONENTS_BUILD="CLOOG GCC"

export LD_LIBRARY_PATH="$PREFIX/lib"

for component in ${COMPONENTS_BUILD}
do
	mkdir -p "$PROJECT_DIR"/build/$component
	cd "$PROJECT_DIR"/build/$component

	echo "Configuring $component..."
	SRC_DIR=`ls -d ../../"$component"/*`
	eval configure_cmd=\${${component}_CONFIGURE}
	eval echo "${configure_cmd}"
	eval ${configure_cmd} || fatal "Cannot configure $component"
	make || fatal "Cannot build $component"
	make install || fatal "Cannot install $component into $PREFIX"
	cd - 2>&1 > /dev/null
done

