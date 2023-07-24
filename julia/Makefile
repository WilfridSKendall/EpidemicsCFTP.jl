SHELL := /usr/bin/bash

QUARTO         := /usr/local/bin/quarto
CSL            := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash --csl=$(CSL)

main: figures.pdf production.pdf experiment.pdf docs

docs: EpidemicsUtilities/docs/build/EpidemicsUtilities.qmd
	$(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)

clean:
	-rm $(wildcard image/DIFF_*.png)
	-rm $(wildcard *.ipynb)
	$(HOME)/.local/bin/julia -e 'Base.compilecache(Base.identify_package("EpidemicsUtilities"))'

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
EpidemicsUtilities/docs/build/EpidemicsUtilities.qmd: EpidemicsUtilities/src/EpidemicsUtilities.jl	
	$(HOME)/.local/bin/julia -e 'using Literate; Literate.markdown("$^",flavor = Literate.DocumenterFlavor(), codefence="```{julia}" => "```")'
	mv EpidemicsUtilities.md EpidemicsUtilities/docs/build/EpidemicsUtilities.qmd

%.pdf: %.qmd EpidemicsUtilities/src/EpidemicsUtilities.jl ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)

.INTERMEDIATE: EpidemicsUtilities.qmd EpidemicsUtilities/docs/build/EpidemicsUtilities.qmd
