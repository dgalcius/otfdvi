otfdvi:=../../otfdvi.lua


defaults: 01.pdf

%.dvi:  %.tex
	dvilualatex $*

%.pdf:  %.dvi .FORCE
	$(otfdvi) $*.dvi
	make -f __Makefile all pdf clean
	mv out.pdf $@ 


clean:
	rm -f out*
	rm -f *.aux *.log *.fls
	rm -f __Makefile ttfonts.map
	rm -f *.glyphs

test:
#	$(otfdvi) foobar --help --output=123 --fake -n 999 -S lopas - -1 -2 -3
	$(otfdvi) --version

.PRECIOUS: %.dvi

.FORCE:

ttc:
	~/Downloads/ttf2ttc/split_ttcf.pl --output-prefix=fkaka --input-ttf=Chalkboard.ttc 
	~/Downloads/ttf2ttc/merge2ttcf.pl  --output-file=chalkboard-1.ttf fkaka_0*.sdat 
	ttf2pt1 chalkboard-1.ttf 
#	ftdump sazanami.ttc
# 	ttfdump --help
