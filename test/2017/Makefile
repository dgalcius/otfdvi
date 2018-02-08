otfdvi:=../../otfdvi.lua


ps: 01.ps 02.ps

%.dvi:  %.tex
	dvilualatex $*

%.pdf:  %.dvi
	$(otfdvi) $*.dvi
	make -f __Makefile all pdf clean
	mv out.pdf $@ 


clean:
	rm -f out*
	rm -f *.aux *.log *.fls
	rm -f __Makefile ttfonts.map

.PRECIOUS: %.dvi
