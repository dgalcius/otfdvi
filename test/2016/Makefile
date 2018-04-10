otfdvi:=../../otfdvi.lua

default: 01.ps

ps: 01.ps 02.ps

%.dvi:  %.tex
	dvilualatex $*

%.ps:  %.dvi
	$(otfdvi) $*.dvi
	make -f __Makefile all pdf clean


clean:
	rm -f out*
	rm -f *.aux *.log *.fls
	rm -f __Makefile ttfonts.map

.PRECIOUS: %.dvi
