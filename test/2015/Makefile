otfdvi:=../../otfdvi.lua


default: 01.pdf

%.dvi:  %.tex
	dvilualatex $*

%.pdf:  %.dvi
	$(otfdvi) $*.dvi
	make -f __Makefile fonts pdf clean



clean:
	rm -f out*
	rm -f *.aux *.log *.fls
	rm -f __Makefile ttfonts.map
