

default: foo.pdf

%.html: %.tex .FORCE
	make4ht -u -c ./nma.cfg foo.tex


%.pdf: %.tex .FORCE
	pdflatex -recorder $<

tidy:
	tidy -utf8  -b -i -o out.html foo.html

clean:
	rm -rf *.aux *.log *.html *.pdf *.4ct *.4tc *.css *.idv *.xref

.FORCE:


