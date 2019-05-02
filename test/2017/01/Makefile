otfdvi:=../../../otfdvi


defaults: 01.pdf

%.dvi:  %.tex .FORCE
	dvilualatex -recorder $*

06.dvi: 06.tex .FORCE
	vtex 2016 luatex_dvi 06

%.l.pdf:  %.tex
	lualatex -jobname=$*.l -recorder $*

%.ps:  %.dvi .FORCE
	$(otfdvi) $*.dvi
#	make -f __Makefile fonts ps
#	mv out.ps $@

%.pdf:  %.dvi .FORCE
	$(otfdvi) $*.dvi
#	make -f __Makefile fonts pdf clean
#	make -f __Makefile fonts pdf
  #clean
#	mv out.pdf $@
#	pdflatex diff



clean:
	rm -f out*
	rm -f *.aux *.log *.fls *.enc
	rm -f __Makefile ttfonts.map
	rm -f *.glyphs
	rm -f *.tfm

testx:
#	$(otfdvi) --help --output=123 --fake -n 999 -S lopas - -1 -2 -3
#	$(otfdvi) --version
#	$(otfdvi) --help
	$(otfdvi) -c myconfig.lua -f afont -daH  -p xxx.map -m 00Makefile  01.dvi foo.dvi

check: 01.check

%.check: %.ps
	diff -I '^.*Date' -I '^.*DVIPSSource' $*.ps $*.test.ps



.PRECIOUS: %.dvi

.FORCE:

ttc:
	~/Downloads/ttf2ttc/split_ttcf.pl --output-prefix=fkaka --input-ttf=Chalkboard.ttc 
	~/Downloads/ttf2ttc/merge2ttcf.pl  --output-file=chalkboard-1.ttf fkaka_0*.sdat 
	ttf2pt1 chalkboard-1.ttf 
#	ftdump sazanami.ttc
# 	ttfdump --help
