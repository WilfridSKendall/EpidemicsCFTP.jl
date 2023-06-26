SHELL := /usr/bin/bash

QUARTO := /usr/local/bin/quarto
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash

main: figures.pdf production.pdf

production.qmd: preliminary.jl
	
clean: ; rm figures.ipynbmake

verify: figures.pdf production.pdf
	@for f in $(wildcard image/REFERENCE_*.png) ; do  \
	( if cmp -s $${f/REFERENCE_/} $$f ;               \
	  then echo Checked $${f/REFERENCE_/};            \
	  else \
	    ( ( compare $${f/REFERENCE_/} $$f  $${f/REFERENCE_/DIFF_} ) ;                          \
	      ( convert +append $${f/REFERENCE_/}  $${f/REFERENCE_/DIFF_} $$f miff:- | display ) ; \
	        echo Issue with $${f/REFERENCE_/} see $${f/REFERENCE_/DIFF_} ) ;                   \
	  fi ) ; \
	done

set-up-verify: ; for f in image/*.png ; do cp $$f $${f/image\//image\/REFERENCE_} ; done

%.pdf: %.qmd   ; $(QUARTO) render $^ --to pdf $(QUARTO_OPTIONS)
