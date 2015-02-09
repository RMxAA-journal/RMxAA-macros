#! /bin/sh
VERSION=1.12
DATE="06 Feb 2003"
###################################################################################
########################            splitbook.sh              #####################
###################################################################################
##
## AUTHOR: W. Henney (will@astrosmo.unam.mx)
## VERSION: 1.12(06 Feb 2003) Option to choose which copyright info to include
## VERSION: 1.11(04 Feb 2003) Made LinHi the default printer option
## VERSION: 1.10(09 Jan 2003) Added -Ppdf -Pamz -G0 to dvips options when
##                            generating PDF. Also now does PDF1.3 (nobody still
##                            uses Acrobat 3 I hope!)
## VERSION: 1.9 (26 Apr 2002) removed ./ in front of fixbb.sh!
## VERSION: 1.8 (21 Mar 2002) added extra options to ps2pdf
## VERSION: 1.7 (04 Mar 2002) rewrite to allow mainmatter to not start 
##                            on page 1
## VERSION: 1.6 (08 Nov 2001) put ./ in front of fixbb.sh 
##                            put #!\bin\sh at top of .dvips files
##                            removed -s & -o options
##                            rationalized subdirs (EPS, PSZ, PDF)
##                            rationalized suffix of dvips scripts
## VERSION: 1.5 (30 May 2001) Now allows multi-word frontsections 
## VERSION: 1.4 (29 May 2001) Properly fixed to work on Solaris 
## VERSION: 1.3 (06 Feb 2001) Fixed to work on Solaris
## VERSION: 1.2 (10 May 2000)
## VERSION: 1.1 (16 Feb 2000)
##
## Part of the RevMexAA LaTeX package
##
## COPYING: GPL
##
## USAGE:
##
## splitbook.sh [-v] [-p PREFIX] [-P PRINTER] FILEROOT
##
## BRIEF DESCRIPTION:
##
## Uses information in the .aux file to produce a series of dvips commands
## which post-process a .dvi file created with the `book' option 
## in order to produce a separate .ps file for each paper.
##
##
## This is an order N^2 algorithm, but it seems to be fast enough
##
## STATUS: works fine in most cases
##
## ACKNOWLEDGEMENTS: 
##
## Thanks to William Lee and Alberto Carrami~nana for bug reports. 
##
echo "This is splitbook.sh, v.$VERSION ($DATE)"

# Token attempt at portability
OS=`uname -s`
if [ $OS = 'Linux' ]; then
    AWK=awk
elif [ $OS = 'SunOS' ]; then
    AWK=nawk
else
    echo "Warning: Unrecognised OS. Assuming you have a functioning awk"
    AWK=awk
fi

# list of files to clean up at the end
TMPFILELIST=""

# sed script that cleans up the \newlabel lines in the .aux file
SEDFILE=sed.tmp$$
TMPFILELIST="$TMPFILELIST $SEDFILE"
cat > $SEDFILE <<EOF 
s/\\\\newlabel//g
s/{\\\\upshape//g
s/{/:/g
s/}//g
s/:RMAA.*Page/:/g
EOF

EPSDIR="EPS"
PSZDIR="PSZ"
PDFDIR="PDF"
if [ ! -d $PDFDIR ]; then
    mkdir $PDFDIR
fi
if [ ! -d $EPSDIR ]; then
    mkdir $EPSDIR
fi
if [ ! -d $PSZDIR ]; then
    mkdir $PSZDIR
fi
OUTFILE=""
OUTPREFIX=""
VERBOSE="FALSE"
PRINTEROPT="-PLinHi"
COPYRIGHT="RMSC"
## got these from posting on comp.text.tex
## see also http://www.cs.wisc.edu/~ghost/doc/AFPL/7.04/Ps2pdf.htm
## and http://partners.adobe.com/asn/developer/acrosdk/docs/distparm.pdf
## supposedly improve handling of images
PS2PDF="ps2pdf13"
PS2PDF_OPTIONS="-dUseFlateCompression=true \
                -dEncodeColorImages=false \
                -dDownsampleColorImages=false \
		-dAntiAliasColorImages=true \
		-dAutoRotatePages=/None"


# process options 
while getopts :p:P:c:v OPT; do
    case $OPT in
	p|+p)
	    OUTPREFIX="$OPTARG"
	    ;;
	P|+P)
	    PRINTEROPT="-P$OPTARG"
	    ;;
	c|+c)
	    COPYRIGHT="$OPTARG"
	    ;;
	v|+v)
	    VERBOSE="TRUE"
	    ;;
	*)
	    echo "usage: `basename $0` [-P PRINTER] [-c COPYRIGHT] [-p PREFIX] [-v] FILEROOT"
	    exit 2
    esac
done
shift `expr $OPTIND - 1`

# set name of root file
FILEROOT=$1

if [ -z "$OUTPREFIX" ]; then
    OUTPREFIX="${FILEROOT}"
fi
if [ ! -f $FILEROOT.aux ]; then
    echo "You must run LaTeX to generate $FILEROOT.aux before running this script"
    exit 2
fi

# another file for the EPS pages
OUTFILE2="${FILEROOT}.makeEPS"
# another file for the gzipped articles without numbers in the name
OUTFILE3="${FILEROOT}.makePSZ"
# another file for the PDF articles with Type 1 fonts
OUTFILE4="${FILEROOT}.makePDF"

# remove output file if present
if [ -f $OUTFILE2 ]; then
    mv $OUTFILE2 $OUTFILE2.BCK
fi
if [ -f $OUTFILE3 ]; then
    mv $OUTFILE3 $OUTFILE3.BCK
fi
if [ -f $OUTFILE4 ]; then
    mv $OUTFILE4 $OUTFILE4.BCK
fi

# make sure all output files run under sh, not csh
echo >> $OUTFILE2 "#!/bin/sh"
echo >> $OUTFILE3 "#!/bin/sh"
echo >> $OUTFILE4 "#!/bin/sh"

i=1 # initialise counter used in constructing the file names
cumpages=0
frontpages=0
FirstArticle='TRUE' 

# one pass through the .aux file to get a list of all the articles
articlelist=`grep RMAAFirst $FILEROOT.aux|sed -f $SEDFILE|cut -d':' -f2|sed -e 's/ /_/g'`

# make version of .aux file that has '_' instead of ' '
AUXFILE2=$FILEROOT.aux$$
TMPFILELIST="$TMPFILELIST $AUXFILE2"
sed -e 's/ /_/g' $FILEROOT.aux > $AUXFILE2

numarticles=`echo $articlelist|wc -w`

echo "Found $numarticles separate articles."

if [ $VERBOSE = 'TRUE' ]; then
    echo "Articles are: " $articlelist
fi

# now loop through each name on this list
for name in $articlelist ; do

    ID=`printf "%3.3i" $i` # format ID number (hard limit of 999 individual papers)

    # find the TeX page numbers for start and end of article
#    Tfirstpage=`grep "{$name:RMAAFirst" $FILEROOT.aux | sed -f $SEDFILE | cut -d':' -f6`
    Tfirstpage=`grep "{$name:RMAAFirst" $AUXFILE2 | sed -f $SEDFILE | cut -d':' -f6`
    if [ -z "$Tfirstpage" ]; then
	echo "ERROR: First page number not found in article $name"
    fi
#    Tlastpage=`grep "{$name:RMAALast" $FILEROOT.aux | sed -f $SEDFILE | cut -d':' -f6`
    Tlastpage=`grep "{$name:RMAALast" $AUXFILE2 | sed -f $SEDFILE | cut -d':' -f6`
    if [ -z "$Tlastpage" ]; then
	echo "ERROR: Last page number not found in  article $name"
    fi

    platelist=`grep "{$name:RMAAPlate" $FILEROOT.aux | sed -f $SEDFILE| sed -e 's/RMAAPlate/:/g' | cut -d':' -f4`


    if [ $VERBOSE = 'TRUE' ]; then
	echo "Article: $name Firstpage: $Tfirstpage Lastpage: $Tlastpage Plate list: $platelist" 
    fi

    # check if we are in the frontmatter
    MAYBE_F=`echo $Tfirstpage|cut -c1`


    # Work out physical pages
    if [ "$MAYBE_F" = 'F' ]; then
	# if so, cut the `F' off the front of the page num
	Tfirstpage=`echo $Tfirstpage|cut -c2-`
	Tlastpage=`echo $Tlastpage|cut -c2-`
	# subtract 2 to get the physical pages since we don't do the first 2 pages
	Pfirstpage=`expr $Tfirstpage - 2`
	Plastpage=`expr $Tlastpage - 2`
	# set the total number of (physical) pages of frontmatter
	frontpages=`expr $Plastpage + 1`
	frontpages=`expr $frontpages / 2`; frontpages=`expr $frontpages \* 2` # make sure it is even
	if [ $VERBOSE = 'TRUE' ]; then
	    echo "Pages of front matter:  $frontpages"
	fi

    else
	# Check for SetFirstPage
	[ $FirstArticle = 'TRUE' ] && MainMatterFirstPage=$Tfirstpage
	FirstArticle='FALSE' # turn off for subsequent articles 
	
	# otherwise add the frontmatter pages to the TeX page number 
	# to get a physical page number
	# 04 Mar 2002: correction if articles do not start on p. 1
	Pfirstpage=`expr $Tfirstpage + $frontpages - $MainMatterFirstPage + 1`
	Plastpage=`expr $Tlastpage + $frontpages - $MainMatterFirstPage + 1`
    fi

    ### New algorithm 04 Mar 2002
#    numpages=`expr $Tlastpage - $Tfirstpage + 1`
#    Pfirstpage=`expr $cumpages + 1`
#    # check for an intervening blank page
#    if [ "$MAYBE_F" -ne 'F' -a $Tfirstpage -ne $Tafterprevlastpage ]; then
#	Pfirstpage=`expr $Pfirstpage + 1`
#    fi
#    Plastpage=`expr $Pfirstpage + $numpages - 1`
#    cumpages=$Plastpage

    if [ "z$platelist" = 'z' ]; then
	## Case of no plates in article - use physical page numbers
	# construct a dvips page range with the physical page numbers
	DVIPSRANGE="-p =$Pfirstpage -l =$Plastpage"
    else
	## Case where we do have plates - use TeX page numbers so we can 
	## accumulate non-contiguous pages with the -pp option
	Tfirstplatepage=999999
	for plate in $platelist; do
	    platepage=`grep "{RMAAOutputPlate$plate" $FILEROOT.aux | sed -f $SEDFILE | cut -d':' -f5`
	    if [ $platepage -lt $Tfirstplatepage ]; then
		Tfirstplatepage=$platepage
	    fi
	    Tlastplatepage=$platepage
	done
	numpages=`expr $Tlastpage - $Tfirstpage + 1`
	numpageplus=`expr $numpages + 1`
	if [ `expr $numpages / 2` -ne `expr $numpageplus / 2` ]; then
	    # odd number of article pages - put in extra blank page
	    Tfirstplatepage=`expr $Tfirstplatepage - 1`
	    # this will not work if the book has an even number of pages
	fi
	Tlastplatepage=`expr $Tlastplatepage + 1` # add on the blank page after
	# also work out the physical plate pages for use in the EPS files
	Pfirstplatepage=`expr $Tfirstplatepage + $frontpages`
	Plastplatepage=`expr $Tlastplatepage + $frontpages`

	# now construct a dvips page range with the TeX page numbers
	# of both the article and the plate(s)
	DVIPSRANGE="-pp ${Tfirstpage}-${Tlastpage},${Tfirstplatepage}-${Tlastplatepage}"
	# We are forced to use TeX page numbers here, since we need the -pp option
	# in order to accumulate non-consecutive pages and this doesn't accept
	# physical pages (as of dvips 5.85)
	# As a result, funny things will happen if an article with plates has 
	# a starting pagenumber <= the number of pages of frontmatter.
	# Hopefully, this will be rare!
    fi
 
    # output the dvips command line
    PSFILE3=${PSZDIR}/${OUTPREFIX}_$name.ps
    PDFFILE=${PDFDIR}/${OUTPREFIX}_$name.pdf
    echo >> $OUTFILE3 "dvips -o  $PSFILE3 $DVIPSRANGE $FILEROOT -P$COPYRIGHT && gzip -fv $PSFILE3"
    echo >> $OUTFILE4 "dvips $DVIPSRANGE $FILEROOT -Pcmz -Pamz -Ppdf -G0 -P$COPYRIGHT -f | $PS2PDF $PS2PDF_OPTIONS - $PDFFILE"
    
    #### now do the commands for PS files of individual pages
    pp=$Pfirstpage
    echo >> $OUTFILE2 "# $name"
    laplist=`$AWK "BEGIN { for( i=$Tfirstpage; i<=$Tlastpage; i++ ) print i }"`
    if [ $VERBOSE = 'TRUE' ]; then
	echo "LaTex page list: $laplist (should be $Tfirstpage - $Tlastpage)"
    fi
    for lap in $laplist; do
	if [ $VERBOSE = 'TRUE' ]; then
	    echo "$lap (LaTeX)  $pp (physical)"
	fi
	if [ $MAYBE_F = 'F' ]; then
	    PID="F`printf "%3.3i" $lap`"
	else
	    PID=`printf "%3.3i" $lap`
	fi
	# Name of EPS file of this page
	EPSFILE=${EPSDIR}/${OUTPREFIX}${PID}.eps
	# Tell dvips to just do this physical page
	DVIPSRANGE="-p =$pp -l =$pp"
	# Write dvips command line to file
	# Use the `-E' option to produce eps file, but then restore whole page
	# BoundingBox with the `fixbb.sh' script
	echo >> $OUTFILE2 "dvips -E $PRINTEROPT $FILEROOT $DVIPSRANGE -o $EPSFILE && fixbb.sh $EPSFILE"
	pp=`expr $pp + 1`
    done
    #### and the same for the plates if they are there
    if [ "z$platelist" != 'z' ]; then
	pp=$Pfirstplatepage
	echo >> $OUTFILE2 "# $name: Plates"
	laplist=`$AWK "BEGIN { for( i=$Tfirstplatepage; i<=$Tlastplatepage; i++ ) print i }"`
	if [ $VERBOSE = 'TRUE' ]; then
	    echo "LaTex page list for plates: $laplist"
	fi
	for lap in $laplist; do
	    if [ $VERBOSE = 'TRUE' ]; then
		echo "$lap (LaTeX)  $pp (physical)"
	    fi
	    PID="P`printf "%3.3i" $lap`"
	    # Name of EPS file of this page
	    EPSFILE=${EPSDIR}/${OUTPREFIX}${PID}.eps
	    # Tell dvips to just do this physical page
	    DVIPSRANGE="-p =$pp -l =$pp"
	    echo >> $OUTFILE2 "dvips -E $PRINTEROPT $FILEROOT $DVIPSRANGE -o $EPSFILE && fixbb.sh $EPSFILE"
	    pp=`expr $pp + 1`
	done
    fi



#    # 04 Mar 2002 save this for later
#    Tafterprevlastpage=`expr $Tlastpage + 1`

    i=`expr $i + 1` # increment counter
done

# clean up
chmod a+x $OUTFILE2 $OUTFILE3 $OUTFILE4
echo "A dvips script has been written to $OUTFILE2."
echo "Run that file to generate EPS files for each individual page." 
echo "These files will have names of the form  ${OUTPREFIX}_####.ps"
echo "and will be put in the $EPSDIR directory."
echo 
echo "Copyright info will be included on each page of the gzipped PostScript"
echo "and PDF files from the file ${COPYRIGHT}config.ps - please edit that file"
echo "to include the correct date and conference details (if appropriate)." 
echo
echo "Another dvips script has been written to $OUTFILE3."
echo "Run that file to generate gzipped PostScript files for each article."
echo "These files will have names of the form  ${OUTPREFIX}_<NAME>.ps.gz"
echo "that can be linked from the web page and will be put in"
echo "the $PSZDIR directory."
echo
echo "Yet another dvips script has been written to $OUTFILE4."
echo "Run that file to generate PDF files for each article."
echo "PDF files will have names of the form  ${OUTPREFIX}_<NAME>.pdf"
echo "that can be linked from the web page and will be put in"
echo "the $PDFDIR directory."
echo

rm -f $TMPFILELIST
exit 0