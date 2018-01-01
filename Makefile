SHELL=/usr/bin/env bash


texdvi=dvilualatex -recorder

default: test.dvi

test.dvi: sample2e.dvi 
	ruby otfdvi.rb $< $@


1: sample2e.dvi 
	ruby otfdvi.rb  $< test.dvi
	dvips -j1 -u ttfonts.map -o sample2e.ps test.dvi
	ps2pdf sample2e.ps
	rm -f test.* *.pfb *.enc *.tfm *.otf

2: sample2e.dvi 
	ruby otfdvi.rb --no-auto --no-htf $< test.dvi
	dvips -j1 -u test.map -o sample2e.ps test.dvi
	ps2pdf sample2e.ps
#	rm -f test.* *.pfb *.enc *.tfm *.otf

%.dvi: %.tex .FORCE
	$(texdvi) $<


html: sample2e.tex .FORCE
	./dviluahtlatex $< "xhtml,4,new-accents"
	ruby otfdvi.rb --no-auto --inplace sample2e.dvi 
	tex4ht -f/sample2e.dvi  
	t4ht -f/sample2e.dvi
	make -f 00Makefile clean


clean:
	rm -f *.aux *.dvi *.fls *.log 
.FORCE:
