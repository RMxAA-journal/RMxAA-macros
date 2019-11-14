RMVERSION=4.0pre

STYFILES=rmaa.cls rmaa.bst
DOCFILES=authorguide.tex rmeditor.tex
SAMPFILES=rm-journal-example.tex
SAMPFILES_PS=$(SAMPFILES:.tex=.ps)
SAMPFILES_PDF=$(SAMPFILES:.tex=.pdf)
SCSAMPFILES=rm-extenso.tex rm-onepage.tex rm-shortabstract.tex
SCSAMPFILES_PS=$(SCSAMPFILES:.tex=.ps)
SCSAMPFILES_PDF=$(SCSAMPFILES:.tex=.pdf)

FIGFILES=example-fig.eps example-badfig.eps example-fig.pdf example-badfig.pdf \
  ORCIDiD_iconvector.eps ORCIDiD_iconvector.pdf
#SAMPFILES=rmtest.tex rmprocsamp.tex rmpostsamp.tex rmplatesamp.tex 
#PSFILES=rmprocsamp_fig1.ps rmprocsamp_fig2.ps rmprocsamp_fig3.ps rmplatesamp_fig.ps
MISCFILES=README GPL 

EDITORSTYFILES=rmaa.ist adshtml.sty
EDITORSAMPFILES=rmbooksamp.tex rmbooksamp_HTOC.tex rmsummsamp.tex rm-minimal-test.tex $(SAMPFILES) $(SCSAMPFILES)
EDITORUTILFILES=splitbook.sh fixbb.sh fixhtml.sh sanitizeps.sh makeads.sh \
  config.LinHi config.RMSC config.RMAA RMAAheader.ps RMSCheader.ps \
  adshtml.perl .latex2html-init
EDITORPSFILES=rmsc.ps rmsc_blank.ps 
EDITORPDFFILES=$(EDITORPSFILES:.ps=.pdf)
EDITORDOCFILES=rm-fulldocs.pdf rmeditor.tex

HTMLDIR=html

HTMLFILES=index.html individ.html bugs.html README .htaccess

# files to go in normal tarball
FILES=$(STYFILES) authorguide.pdf $(SAMPFILES) $(FIGFILES) $(MISCFILES)

# new distro specifically for the Conference Series
SCFILES=$(STYFILES) rmsc-authorguide.pdf $(SCSAMPFILES) $(FIGFILES) README.rmsc GPL

# files to go in editor tarball
EDFILES=$(FILES) $(EDITORSTYFILES) rmsc-authorguide.pdf $(EDITORSAMPFILES) $(EDITORPSFILES) $(EDITORPDFFILES) $(EDITORUTILFILES) $(EDITORDOCFILES)

# files to be copied to web dir for individual download
INDIVIDFILES=$(STYFILES) $(DOCFILES) $(SAMPFILES) $(PSFILES) $(MISCFILES) \
 $(EDITORSTYFILES) $(EDITORSAMPFILES) $(EDITORPSFILES) $(EDITORUTILFILES)

DOCPDFS=authorguide.pdf rmsc-authorguide.pdf README README.rmsc

ZIPFILE=rmaa$(RMVERSION).zip
TGZFILE=rmaa$(RMVERSION).tar.gz
EDZIPFILE=rmaa_editor$(RMVERSION).zip
EDTGZFILE=rmaa_editor$(RMVERSION).tar.gz
SCZIPFILE=rmsc$(RMVERSION).zip
SCTGZFILE=rmsc$(RMVERSION).tar.gz

# The live site
WEBDIR=/http/pub/w.henney/rmaa
# The beta test site
BETADIR=/http/pub/w.henney/rmaa/beta
WEBHOST=ssh.crya.unam.mx
# Test site on my laptop
LOCALWEBDIR=~/tmp/RMAAsite

# Solaris
#MV=/usr/bin/mv
#LN=/usr/bin/ln -s
# Linux
MV=/bin/mv -f
LN=/bin/ln -s -f
RM=/bin/rm -f
INSTALL=/usr/bin/install -p 
#PWD=/home/will/latex/inputs/RMAA
PWD := $(shell pwd)

all: publish-local

# precompiled versions of documentation
rmsc-authorguide.pdf: rmsc-authorguide.tex 
	pdflatex $<; pdflatex $<
authorguide.pdf: authorguide.tex 
	pdflatex $<; pdflatex $<

# precompiled versions of example files
rm-extenso.ps: rm-extenso.tex 
	latex $<; latex $<; dvips $(<:.tex=.dvi) -o
rm-onepage.ps: rm-onepage.tex 
	latex $<; latex $<; dvips $(<:.tex=.dvi) -o
rm-shortabstract.ps: rm-shortabstract.tex 
	latex $<; latex $<; dvips $(<:.tex=.dvi) -o
rm-journal-example.ps: rm-journal-example.tex 
	latex $<; latex $<; dvips $(<:.tex=.dvi) -o
rm-ex3.ps: rm-ex3.tex 
	latex $<; latex $<; dvips $(<:.tex=.dvi) -o

rm-extenso.pdf: rm-extenso.tex 
	pdflatex $<; pdflatex $<
rm-onepage.pdf: rm-onepage.tex 
	pdflatex $<; pdflatex $<
rm-shortabstract.pdf: rm-shortabstract.tex 
	pdflatex $<; pdflatex $<
rm-journal-example.pdf: rm-journal-example.tex 
	pdflatex $<; pdflatex $<
rm-ex3.pdf: rm-ex3.tex 
	pdflatex $<; pdflatex $<



DISTROFILES=$(TGZFILE) $(ZIPFILE) $(SCZIPFILE) $(SCTGZFILE) $(EDTGZFILE) $(EDZIPFILE)

$(ZIPFILE): $(FILES)
	zip $@ $^
$(TGZFILE): $(FILES)
	tar -cvzf $@ $^

$(SCZIPFILE): $(SCFILES) 
	zip $@ $^
$(SCTGZFILE): $(SCFILES) 
	tar -czvf $@ $^

$(EDZIPFILE): $(EDFILES)
	zip $@ $^
$(EDTGZFILE): $(EDFILES)
	tar -cvzf  $@ $^

distrolinks: $(DISTROFILES)
	$(LN) $(ZIPFILE) rmaa.zip
	$(LN) $(SCZIPFILE) rmsc.zip
	$(LN) $(TGZFILE) rmaa.tar.gz
	$(LN) $(SCTGZFILE) rmsc.tar.gz
	$(LN) $(EDTGZFILE) rmaa_editor.tar.gz
	$(LN) $(EDZIPFILE) rmaa_editor.zip

publish-live: distrolinks $(DOCPDFS)
	rsync -avzP $(DISTROFILES) $(WEBHOST):$(WEBDIR)
	rsync -avzP $(DOCPDFS) $(WEBHOST):$(WEBDIR)
	rsync -avzP $(HTMLDIR)/*.html $(HTMLDIR)/.htaccess $(WEBHOST):$(WEBDIR)

publish-beta: distrolinks $(DOCPDFS)
	rsync -avzP $(DISTROFILES) $(WEBHOST):$(BETADIR)
	rsync -avzP $(DOCPDFS) $(WEBHOST):$(BETADIR)
	rsync -avzP $(HTMLDIR)/*.html $(HTMLDIR)/.htaccess $(WEBHOST):$(BETADIR)


publish-local: distrolinks $(DOCPDFS)
	rsync -avzP $(DISTROFILES) $(LOCALWEBDIR)
	rsync -avzP $(DOCPDFS) $(LOCALWEBDIR)
	rsync -avzP $(HTMLDIR)/*.html $(HTMLDIR)/.htaccess $(LOCALWEBDIR)

