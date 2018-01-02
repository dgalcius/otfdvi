SHELL:=/usr/bin/env bash
otffonts=%{otffonts}
encfiles=%{encfiles}
tfmfiles=%{tfmfiles}
htffiles=%{htffiles}

out=%{output}
mapfile=%{psmapfile}
dvifile=${out}.dvi
psfile=${out}.ps
pdffile=${out}.pdf

verbose=%{verbose}

define cp_k
	if [[ ! -f $(1) ]]; then x=`kpsewhich $(1)`; cp $$x $(1) ; fi
endef


define tfm_gen
	otftotfm --name=$(1) --literal-encoding=$(1).enc\
  --vendor=ZZZ --use-x-height\
  --no-encoding $(verbose) $(2) >> $(3)
endef

default: all

all: otffonts tfmfiles

otffonts: $(otffonts)

tfmfiles: $(tfmfiles)

pdf: $(pdffile)
	@echo  Output $<

ps: $(psfile)
	@echo Output $<

${otffonts}:
	 $(call cp_k,$@)

${psfile}: ${dvifile}
	dvips -j1 -u ${mapfile} -o $@ $<

${pdffile}: ${psfile}
	ps2pdf $<

clean:
	rm -f $(otffonts) $(tfmfiles) $(encfiles) $(htffiles) $(mapfile) *.pfb
	rm -f ttfonts.map

.FORCE:

