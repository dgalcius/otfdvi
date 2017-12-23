
texdvi=dvilualatex -recorder

default: test.dvi

test.dvi: sample2e.dvi
	ruby otfdvi.rb $< $@ 


%.dvi: %.tex
	$(texdvi) $<

#%.dt: %.dvi
#	dv2dt $< $@
#
#%.dvi: %.dt
#	dt2dv $< $@

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

1: lmroman10-regular.otf
#	otftotfm --help > otftotfm.help
#  --literal-encoding=font-a01
	otftotfm\
  --literal-encoding=font-14\
  --vendor=ZZZ --typeface="font-14"\
  --name=font-14 $< >00.map

# do not gen encoding, pfb, and map
# we generate pfb with cfftopt1
# encoding and map file we generate on the fly
2: 
	otftotfm\
  --literal-encoding=font-14\
  --vendor=lcdftools --typeface="font-14"\
  --no-type1 --no-encoding --no-map --verbose  lmroman10-regular.otf 

#  --encoding=font-14\

00.dvi: 00.dt
	dt2dv $< $@

00.ps: 00.dvi
	dvips -j0 -M -u 00.map $<

reencode:
	t1reencode -e a_swtzzr.enc --name=font-a01 --full-name=font-a01 -a -o font-a01.pfa LMRoman10-Regular.pfb 

