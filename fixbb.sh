#! /bin/sh

# Token attempt at portability
# ah, the vagaries of sed
OS=`uname -s`
if [ $OS = 'Linux' ]; then
    BRANCHTOEND='b 2'
elif [ $OS = 'SunOS' ]; then
    BRANCHTOEND='b'
else
    echo "Warning: Unrecognised OS. Assuming Linux-like behaviour of sed"
    BRANCHTOEND='b 2' 
fi

TMP=/tmp
BBOX='0 0 612 792'
while getopts :b: OPT; do
    case $OPT in
	b|+b)
	    BBOX="$OPTARG"
	    ;;
	*)
	    echo "Usage: `basename $0` [-b 'BOUNDING BOX'] \"PSFILES\""
	    echo "Author: W. Henney (10 May 2000)"
	    echo "Changes the BoundingBox of PSFILES to the string given by the"
	    echo "-b option, or to '0 0 612 792' if omitted"
	    echo "Note that \"PSFILES\" must be quoted"
	    exit 2
    esac
done
shift `expr $OPTIND - 1`
FILES="$1"
for file in `ls $FILES`; do
    sed -e "
1,/^%%BoundingBox/{
s/^%%BoundingBox:.*/%%BoundingBox: $BBOX /
$BRANCHTOEND
n
}
: 2 
    " $file > $TMP/fixbb$$.ps
    cp $TMP/fixbb$$.ps $file && echo "Fixed $file"
done

rm -f $TMP/fixbb$$.ps
