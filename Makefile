
texdvi=dvilualatex -recorder

default: sample2e.dvi

%.dvi: %.tex
	$(texdvi) $<

%.dt: %.dvi
	dv2dt $< $@

%.dvi: %.dt
	dt2dv $< $@

sample2x.ps: sample2x.dvi
	dvips -u 01.map -j0 $<

%.pdf: %.ps
	pstopdf $< $@

info: lmroman10-regular.otf
#	otfinfo -i $<
	otfinfo --help $<

tfm: lmroman10-regular.otf
#	otftotfm --help > otftotfm.help
#  --literal-encoding=font-a01
	otftotfm\
  --encoding=font-a01\
  --vendor=ZZZ --typeface=fnta\
  --pl\
  --name=font-a01 $< 


reencode:
	t1reencode -e a_swtzzr.enc --name=font-a01 --full-name=font-a01 -a -o font-a01.pfa LMRoman10-Regular.pfb 

