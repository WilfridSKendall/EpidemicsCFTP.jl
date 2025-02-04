# ~/HTML/WilfridSKendall/PerfectEpidemics
title             := PerfectEpidemics
biblio-source     := CFTP.bib 
version           := VERSION.txt
versionsed        := version.sed

source            := $(title).qmd
biblio            := $(title).bib
macros            := $(title).sty
csl               := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
beamer            := $(title).pdf
handout           := $(title)-handout.pdf
handout-2x2       := $(title)-handout-2x2.pdf
notes             := $(title)-notes.pdf
notes-2x2         := $(title)-notes-2x2.pdf


##################################################

QUARTO	      := /usr/local/bin/quarto
QUARTO_OPT    := --highlight-style tango

INKSCAPE      := /usr/bin/inkscape

.PHONY: main handout notes full see see_handout see_notes \
	web web-GIF web-MP4 web-animations qrcode

##################################################

main:           $(beamer)
handout:        $(handout-2x2)
notes:          $(notes-2x2)

full:           $(handout) $(handout-2x2) $(notes-2x2) $(beamer) \
		README.pdf TODO.pdf

see:            main;           xdg-open $(beamer)
see_handout:    $(handout-2x2); xdg-open $(handout-2x2)
see_notes:      $(notes-2x2);   xdg-open $(notes-2x2)

#################################################

%.pdf: %.qmd $(biblio) $(macros) $(version)
	sed -e "1iThese notes were produced from \`$<\`:\n" -f $(versionsed) $(version)  | \
	$(QUARTO) render $< - --to=beamer $(QUARTO_OPT)                                    \
	--citeproc --bibliography=$(biblio) --csl=$(csl)
	-rm $*.upa

%.tex: %.qmd $(biblio) ; $(QUARTO) render $< --to=latex $(QUARTO_OPT)

%.pdf: %.md
	sed -e "1i----\nThis version of \`$<\`:\n" -f $(versionsed) $(version)  | \
	$(QUARTO) render $< - --to=pdf
	-rm $*.upa $*.upb

$(biblio): $(biblio-source)
	sed --regexp-extended -f $(HOME)/lib/bibfix.sed \
		-e "s/Kendall, Wilfrid Stephen/WSK/"    \
		-e "s/Connor, Stephen B/SBC/"    \
		"$<" > $(biblio)

#################################################

qrcode: image/talk_URL.jpg

web:    web-PDF web-GIF web-MP4
	make -C $(HOME)/HTML/WilfridSKendall deploy

web-PDF: $(title)-handout.pdf $(title)-notes-2x2.pdf $(title).pdf 
	cp $^ $(HOME)/HTML/WilfridSKendall/talks/$(title)

web-GIF: animation/*.gif
	cp $^ $(HOME)/HTML/WilfridSKendall/talks/$(title)/animation
	
web-MP4: animation/*.mp4
	cp $^ $(HOME)/HTML/WilfridSKendall/talks/$(title)/animation

#################################################

%-handout.pdf: %.qmd $(biblio) $(version)
	sed -e "1iThese notes were produced from \`$<\`:\n" -f $(versionsed) $(version)  | \
	$(QUARTO) render $< - --to=beamer $(QUARTO_OPT) --output $@    \
	--citeproc --bibliography=$(biblio) --csl=$(csl)  \
	-M classoption=handout

%-notes.pdf: %.qmd $(biblio) $(version)
	sed -e "1iThese notes were produced from \`$<\`:\n" -f $(versionsed) $(version)  | \
	$(QUARTO) render $< - --to=beamer $(QUARTO_OPT) --output $@    \
	--citeproc --bibliography=$(biblio) --csl=$(csl)  \
	-M classoption=notes -M classoption=handout

$(version): $(title).qmd ; git log --decorate -1 > $(version)
	
%-2x2.pdf: %.pdf
	$(PDFNUP) --tidy --landscape --frame 'true' --scale '0.95' --nup '2x2' $^ -o $@

image/%.pdf: image/%.svg
	$(INKSCAPE) --export-area-drawing --export-type="pdf" $<

%.jpg: %.png ; convert $^ $@ ; rm $^
: 
	convert -scale 25% "$<" "$@"
	rm "$<" 

image/talk_URL.png:
	qrencode -s 1 -l H -o "$@" \
		"https://wilfridskendall.github.io/talks/$(title)/$(title)-handout.pdf"
