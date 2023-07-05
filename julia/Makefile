SHELL := /usr/bin/bash

QUARTO := /usr/local/bin/quarto
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash

main: figures.pdf production.pdf experiment.pdf FigureUtilities.pdf

clean: ; rm figures.ipynbmake

verify: figures.pdf production.pdf experiment.pdf
	@for f in $(wildcard image/VERIFY_*.png) ; do  \
	( if cmp -s $${f/VERIFY_/} $$f ;               \
	  then echo Checked $${f/VERIFY_/};            \
	  else \
	    ( ( compare $${f/VERIFY_/} $$f  $${f/VERIFY_/DIFF_} ) ;                          \
	      ( convert +append $${f/VERIFY_/}  $${f/VERIFY_/DIFF_} $$f miff:- | display ) ; \
	        echo Issue with $${f/VERIFY_/} see $${f/VERIFY_/DIFF_} ) ;                   \
	  fi ) ; \
	done

set-up-verify: ; for f in image/*.png ; do cp $$f $${f/image\//image\/VERIFY_} ; done

# The following translation is not yet perfect!
# It doesn't include directives "#|" in codeblocks.
FigureUtilities.qmd: FigureUtilities.jl
	$(HOME)/.local/bin/julia -e 'using Literate; Literate.markdown("FigureUtilities.jl",flavor = Literate.CommonMarkFlavor(), codefence="```{julia}" => "```")'
	mv FigureUtilities.md FigureUtilities.qmd

%.pdf: %.qmd FigureUtilities.jl ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)

.INTERMEDIATE: FigureUtilities.qmd
