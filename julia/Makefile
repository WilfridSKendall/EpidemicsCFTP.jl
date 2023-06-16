SHELL := /usr/bin/bash

QUARTO := /usr/local/bin/quarto
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash

figures.pdf: figures.qmd
	$(QUARTO) render $^ --to pdf $(QUARTO_OPTIONS)

clean: ; rm figures.ipynb

verify:
	@for f in $(wildcard image/REFERENCE-*.png) ; \
	  do ( (cmp -s $$f $${f/REFERENCE-/}) || /usr/bin/gwenview $$f $${f/REFERENCE-/} ) ; \
	  done
