SHELL:=/usr/bin/env bash
fonts:={{#targets}} {{fontname}} {{/targets}}
otffonts:={{#targets}} {{otffontname}} {{/targets}}

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

define cp_k
	if [[ ! -f $(1) ]]; then x=`kpsewhich $(1)`; cp $$x $(1) ; fi
endef


default: fonts

fonts: otffonts tfmfonts

otffonts: $(otffonts)

tfmfonts: $(tfmfiles)

pdf: $(pdffile)
	@echo  Output $<

ps: $(psfile)
	@echo Output $<

$(otffonts):
	 $(call cp_k,$@)

$(psfile): $(dvifile)
	dvips -M1 -j1 -u +$(mapfile) -o $@ $<

$(pdffile): $(psfile)
	ps2pdf $<

clean:
	rm -f $(otffonts) $(tfmfiles) $(encfiles) $(htffiles) $(glyphlistfiles)
	rm -f $(mapfile) *.pfb *.mdata
	rm -f __Makefile

.FORCE:

dvipng: $(dvifile)
	dvipng  -T tight $<

dvitype: $(dvifile)
	dvitype $<

dvisvg: $(dvifile)
	dvisvgm --fontmap=+$(mapfile) $<

options:=--vendor=UKWN $(verbose) --no-updmap --warn-missing --x-height=font

{{#targets}}
{{fontname}}.tfm: {{otffontname}} .FORCE
	otftotfm --literal-encoding={{fontname}}.enc  --name={{fontname}} --map-file=$(mapfile) --glyphlist={{glyphsfontname}} --design-size={{design_size}} {{#script}} --script={{script}}{{/script}} $(options) $<

{{/targets}}
