otfdvi:=../../otfdvi.lua

default: 01.pdf

ps: 01.ps 02.ps

%.dvi:  %.tex 
	dvilualatex $*

%.pdf:  %.dvi
	$(otfdvi) $*.dvi
	make -f __Makefile fonts pdf clean


clean:
	rm -f out*
	rm -f *.aux *.log *.fls
	rm -f __Makefile ttfonts.map

.PRECIOUS: %.dvi
