VERSION:=0.1-0
PACKAGE:=otfdvi
bindir:=$(shell kpsewhich -var-value=SELFAUTOLOC)
TEXMFDIST:=$(shell kpsewhich -var-value=TEXMFDIST)
installdir=$(TEXMFDIST)/scripts/lua/otfdvi
files = otfdvi otfdvi.conf.lua otfdvi.tmpl.Makefile

SHELL=/usr/bin/env bash


texdvi=dvilualatex -recorder
otfdvi=./otfdvi

%.dt: %.dvi
	dv2dt $< $@

%.ps:  %.tex
	dvilualatex $*
	$(otfdvi) $*.dvi
	make -f __Makefile all

%.dvi: %.tex 
	$(texdvi) $<


html: sample2e.tex .FORCE
	./dviluahtlatex $< "xhtml,4,new-accents"
	ruby otfdvi.rb --no-auto --inplace sample2e.dvi 
	tex4ht -f/sample2e.dvi  
	t4ht -f/sample2e.dvi
	make -f 00Makefile clean


clean:
	rm -f *.aux *.dvi *.fls *.log
	rm -f *.otf *.tfm *.htf *.enc *.pfb
	rm -f 00Makefile *.map
	rm -f *.glyphlist
	rm -f *.gly
	rm -f *.glyphs
	rm -f *.png
	make -f __Makefile clean


#ln -s /home/deimi/texmf/scripts/lua/make4ht/make4ht /usr/local/bin/make4ht
#/home/deimi/.ltenv/shims/make4ht
install:
	echo INSTALLDIR = $(installdir)
	echo BINDIR = $(bindir)
	mkdir -p $(installdir)
	mkdir -p $(installdir)/lib
	cp $(files) $(installdir)
	cp lib/* $(installdir)/lib
	ln -s ../../texmf-dist/scripts/lua/otfdvi/otfdvi $(bindir)/otfdvi

#include local.mk


.FORCE:
