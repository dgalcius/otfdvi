SHELL:=/usr/bin/env bash
fonts:={{#targets}} {{fontname}} {{/targets}}
otffonts:={{#targets}} {{otffontname}} {{/targets}}

#export T1FONTS=./
#export TTFFONTS=./ 


{{#targets}}
{{{ otffontname }}}:={{{ fullpath }}}
{{/targets}}

encfiles:=$(fonts:=.enc)
tfmfiles:=$(fonts:=.tfm)
htffiles:=$(fonts:=.htf)
glyphlistfiles:=$(fonts:=.glyphs)


output={{output}}
baseout:=$(output:.dvi=)
mapfile:={{psmapfile}}
dvifile:=$(baseout:=.dvi)
psfile:=$(baseout:=.ps)
pdffile:=$(baseout:=.pdf)

{{#verbose}}
verbose:=--verbose=true
{{/verbose}}

default: fonts

fonts: tfmfonts

tfmfonts: $(tfmfiles)

pdf: $(pdffile)
	@echo  Output $<

ps: $(psfile)
	@echo Output $<

$(psfile): $(dvifile)
	dvips -M1 -j1 -u +$(mapfile) -o $@ $<

$(pdffile): $(psfile)
	ps2pdf $<

clean:
	rm -f $(tfmfiles) $(encfiles) $(htffiles) $(glyphlistfiles)
	rm -f $(mapfile) *.pfb *.mdata
	rm -f __Makefile

.FORCE:

dvipng: $(dvifile)
	dvipng  -T tight $<

dvitype: $(dvifile)
	dvitype $<

dvisvg: $(dvifile)
	dvisvgm --fontmap=+$(mapfile) $<

options:=--vendor=UKWN $(verbose) --no-updmap --warn-missing --x-height=font -V --force
options_ttf = --no-type1 --type42

{{#targets}}
## {{fontname}}:
##   otffontname: {{otffontname}}
##   glyphlist: {{glyphsfontname}}
##   design_size: {{design_size}}
##   scale: {{scale}}
##   script: {{script}}
##   language: {{language}}
##   feature: {{feature}}
##   fullpath: {{{fullpath}}}
##   type: {{{otffonttype}}}
{{fontname}}.tfm: export T1FONTS=./
{{fontname}}.tfm: xoptions=$(options) $(options_{{otffonttype}}) 
{{fontname}}.tfm: $({{otffontname}}) .FORCE
	otftotfm --literal-encoding={{fontname}}.enc  --name={{fontname}} --map-file=$(mapfile) --glyphlist={{glyphsfontname}} --design-size={{design_size}} {{#script}} --script={{script}}{{/script}}  $(xoptions) $<

{{/targets}}
