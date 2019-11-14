#! /bin/bash
### Fix up HTML files to get rid of blank lines produced
### by empty author fields
FILEROOT=$1
CALLINGDIR=$PWD

cd $FILEROOT

(cat $CALLINGDIR/RMSC.css ; cat $FILEROOT.css) > TMP$FILEROOT.css \
    && cp TMP$FILEROOT.css $FILEROOT.css 
grep -v '<BR><SPAN  CLASS="textit"></SPAN>' $FILEROOT.html > TMP$FILEROOT.html \
    && cp TMP$FILEROOT.html $FILEROOT.html \
    && rm index.html \
    && ln -s $FILEROOT.html index.html

cd $CALLINGDIR