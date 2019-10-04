otfdvi:=../../otfdvi

f = stefan107
default: $f.pdf

ps: 01.ps 02.ps

%.dvi:  %.tex 
	dvilualatex $*


%.pdf:  %.dvi .FORCE
	$(otfdvi) $*.dvi
	make -f __Makefile fonts pdf clean
#	make -f __Makefile fonts pdf
  #clean
	mv out.pdf $@
	rm -rf out.*


clean:
	rm -f out*
	rm -f *.aux *.log *.fls
	rm -f __Makefile ttfonts.map

.PRECIOUS: %.dvi
.FORCE:
