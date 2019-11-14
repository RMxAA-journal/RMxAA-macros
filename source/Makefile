



DOCFILES=rmaa.pdf
MACRO_LTX_FILES=rmaa.cls rmaacite.sty adshtml.sty
SHELLSCRIPTS=makeads.sh
MACRO_OTHER_FILES=adshtml.perl sample.latex2html-init
MAKEFILE=Makefile
MACROFILES=$(MACRO_LTX_FILES) $(SHELLSCRIPTS) $(MACRO_OTHER_FILES)
SKELETONFILES=ADS.tex
INSTALL=install
INSTALL_DIR=../packages
all: docs macros

install: install-docs install-macros

install-macros: macros
	$(INSTALL) -m 444 $(MACRO_LTX_FILES) $(MACRO_OTHER_FILES) $(INSTALL_DIR)
	$(INSTALL) -m 555 $(SHELLSCRIPTS) $(INSTALL_DIR)
	$(INSTALL) -m 644 $(SKELETONFILES) $(INSTALL_DIR)

install-docs: docs
	$(INSTALL) rmaa.pdf $(INSTALL_DIR)/rm-fulldocs.pdf

docs: $(DOCFILES)

macros: rmaa.dtx rmaa.ins
	touch $(MACROFILES) $(MAKEFILE)
	chmod u+w $(MACROFILES) $(MAKEFILE) rmaa.ins
	latex "\input{rmaa.ins}"
	cp -f $(MAKEFILE) $(MAKEFILE).BCK && unexpand $(MAKEFILE).tex >| $(MAKEFILE) && rm $(MAKEFILE).tex
	chmod a+x $(SHELLSCRIPTS)
	chmod a-w $(MACROFILES) $(MAKEFILE)
	chmod u+w $(SKELETONFILES)

rmaa.idx: rmaa.dtx
	@echo "REGENERATING .idx FILE"
	pdflatex "\nonstopmode\input{rmaa.dtx}"

rmaa.aux: rmaa.dtx rmaa.ind rmaa.gls
	@echo "REGENERATING .aux FILE"
	pdflatex "\nonstopmode\input{rmaa.dtx}"

rmaa.ind: rmaa.idx
	@echo "REGENERATING INDEX"
	makeindex -s gind.ist rmaa

rmaa.gls: rmaa.glo
	@echo "REGENERATING CHANGELOG"
	makeindex -s gglo.ist -o rmaa.gls rmaa.glo

rmaa.pdf: rmaa.aux rmaa.ind rmaa.gls
	@echo "REGENERATING .pdf FILE"
	pdflatex "\nonstopmode\input{rmaa.dtx}"

clean:
	rm -f rmaa.aux rmaa.dvi rmaa.ind rmaa.gls










