SHELL=/usr/bin/env bash


texdvi=dvilualatex -recorder
otfdvi=./otfdvi.lua

default: test.dvi

test.dvi: sample2e.dvi 
	ruby otfdvi.rb $< $@

diff: sample2e.dt out.dt
	diff $^

out.dvi: .FORCE
	./otfdvi.lua

%.dt: %.dvi
	dv2dt $< $@

1: sample2e.dvi 
	 $(otfdvi) $<
#	dv2dt sample2e.dvi sample2e.dt
#	dv2dt out.dvi out.dt
#	make -f __Makefile all dvitype
	make -f __Makefile all pdf 

dvitype: sample2e.dvi 
	 $(otfdvi) $<
	make -f __Makefile all dvitype

ps: sample2e.ps

%.ps:  %.tex
	dvilualatex $*
	$(otfdvi) $*.dvi
	make -f __Makefile all

png: sample2e.dvi 
	 $(otfdvi) $<
	make -f __Makefile all dvipng

svg: sample2e.dvi 
	 $(otfdvi) $<
	make -f __Makefile all svg clean


2: sample2e.dvi 
	ruby otfdvi.rb --no-auto --no-htf --psmap test.map --debug $< test.dvi
	dvips -j1 -u test.map -o sample2e.ps test.dvi
	ps2pdf sample2e.ps
#	rm -f test.* *.pfb *.enc *.tfm *.otf

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
.FORCE:
