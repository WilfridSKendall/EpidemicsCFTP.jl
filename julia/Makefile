SHELL := /usr/bin/bash

QUARTO := /usr/local/bin/quarto
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash

figures.pdf: figures.qmd
production.pdf: production.qmd 

production.qmd: preliminary.jl
	
clean: ; rm figures.ipynb

verify: figures.pdf production.pdf
	@for f in $(wildcard image/REFERENCE-*.png) ; \
	  do ( (cmp -s $$f $${f/REFERENCE-/}) || \
	     ( \
	     compare $${f/REFERENCE-/} $$f -compose src $${f/REFERENCE-/DIFF_} ; \
	     /usr/bin/gwenview $${f/REFERENCE-/} $${f/REFERENCE-/DIFF_} $$f 2> /dev/null ; \
	     ) \
	     ) ; \
	  done
	@echo Checked $(wildcard image/REFERENCE-*.png)

set-up-verify: ; for f in image/*.png ; do cp $$f $${f/image\//image\/REFERENCE-} ; done

%.pdf: %.qmd
	$(QUARTO) render $^ --to pdf $(QUARTO_OPTIONS)
