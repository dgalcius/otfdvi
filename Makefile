SHELL=/usr/bin/env bash


texdvi=dvilualatex -recorder

default: test.dvi

test.dvi: sample2e.dvi 
	ruby otfdvi.rb $< $@

%.dvi: %.tex .FORCE
	$(texdvi) $<

%.html: sample2e.tex .FORCE
	./dviluahtlatex $<
	ruby otfdvi.rb  sample2e.dvi test.dvi
	tex4ht -f/test.dvi  
	t4ht -f/test.dvi  


clean:
	rm -f *.aux *.dvi *.fls *.log 
.FORCE:
