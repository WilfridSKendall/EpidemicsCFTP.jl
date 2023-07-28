SHELL := /usr/bin/bash

QUARTO         := /usr/local/bin/quarto
CSL            := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash --csl=$(CSL)

UTILITIES      := $(wildcard EpidemicsUtilities/src/*.jl)
DOCUMENT       := EpidemicsUtilities/docs/build/EpidemicsUtilities
SOURCE         := EpidemicsUtilities/src/EpidemicsUtilities.jl
SECTIONS       := $(wildcard EpidemicsUtilities/src/0*.jl)

# ====================
# Main targets
main: docs
work: figures.pdf production.pdf experiment.pdf
docs: $(DOCUMENT).pdf

# ====================
# Verification support
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

# ====================
# Documents support
#
# The following translations is not yet perfect!
# It doesn't include directives "#|" in codeblocks.
$(DOCUMENT).qmd: EpidemicsUtilities/docs/build/INTERMEDIATE.jl	
	$(HOME)/.local/bin/julia -e 'using Literate; Literate.markdown("$<", name="$@", documenter=false, flavor = Literate.DocumenterFlavor(), codefence="```{julia}" => "```")'
	mv $(DOCUMENT).qmd.md $(DOCUMENT).qmd

#$(DOCUMENT).qmd: EpidemicsUtilities/docs/build/INTERMEDIATE.jl	
#	$(HOME)/.local/bin/julia -e 'using Literate; Literate.markdown("$<", name="$@", documenter=false, flavor = Literate.DocumenterFlavor(), codefence="```{julia}" => "```")'
#	mv $(DOCUMENT).qmd.md $(DOCUMENT).qmd
	


# ====================
# Intermediate files
.INTERMEDIATE: EpidemicsUtilities/docs/build/INTERMEDIATE.jl

# Concatenation source files into a temporary intermediate file 
# for construction of documentation.
EpidemicsUtilities/docs/build/INTERMEDIATE.jl: $(SOURCE) $(SECTIONS)
	@cat $(SOURCE) $(SECTIONS) > $@
	@echo $(shell date +"%-d %B %Y")
	sed -i -e's/# date: today/# date: $(shell date +"%d %B %Y")/' $@
	@echo $(SECTIONS)

# ====================
# Clean-up
clean:
	-rm $(wildcard image/DIFF_*.png)
	-rm $(wildcard *.ipynb)
	$(HOME)/.local/bin/julia -e 'Base.compilecache(Base.identify_package("EpidemicsUtilities"))'

# ====================
# Automatic conversion of qmd to pdf
%.pdf: %.qmd $(UTILITIES) ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)
