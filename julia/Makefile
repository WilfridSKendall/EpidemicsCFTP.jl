SHELL := /usr/bin/bash

QUARTO         := /usr/local/bin/quarto
CSL            := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash --csl=$(CSL)

main: figures.pdf production.pdf experiment.pdf docs

docs: FigureUtilities/docs/build/FigureUtilities.qmd
	$(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)

clean:
	-rm $(wildcard *.ipynb)
	$(HOME)/.local/bin/julia -e 'Base.compilecache(Base.identify_package("FigureUtilities"))'

verify: figures.pdf production.pdf experiment.pdf
	@for f in $(wildcard image/VERIFY_*.png) ; do  \
	( if cmp -s $${f/VERIFY_/} $$f ;               \
	  then echo Checked $${f/VERIFY_/};            \
	  else \
	    ( ( compare $${f/VERIFY_/} $$f  $${f/VERIFY_/DIFF_} ) ;                   \
	      ( convert +append $${f/VERIFY_/}  $${f/VERIFY_/DIFF_} "$${f/VERIFY_/}"  \
			-annotate +0+10 $$f  miff:-                                   \
			| display ) ;                                                 \
	        echo Issue with $${f/VERIFY_/} see $${f/VERIFY_/DIFF_} ) ;            \
	  fi ) ;                                                                      \
	done

set-up-verify: ; for f in image/*.png ; do cp $$f $${f/image\//image\/VERIFY_} ; done

# The following translation is not yet perfect!
# It doesn't include directives "#|" in codeblocks.
FigureUtilities/docs/build/FigureUtilities.qmd: FigureUtilities/src/FigureUtilities.jl	
	$(HOME)/.local/bin/julia -e 'using Literate; Literate.markdown("$^",flavor = Literate.DocumenterFlavor(), codefence="```{julia}" => "```")'
	mv FigureUtilities.md FigureUtilities/docs/build/FigureUtilities.qmd

%.pdf: %.qmd FigureUtilities/src/FigureUtilities.jl ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)

.INTERMEDIATE: FigureUtilities.qmd FigureUtilities/docs/build/FigureUtilities.qmd
