SHELL          := /usr/bin/bash
MODULE         := EpidemicsUtilities
BUILD          := $(MODULE)/docs/build

QUARTO         := /usr/local/bin/quarto
CSL            := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash --csl=$(CSL)

UTILITIES      := $(wildcard EpidemicsUtilities/src/*.jl)
DOCUMENT       := $(BUILD)/EpidemicsUtilities
SOURCE         := EpidemicsUtilities/src/EpidemicsUtilities.jl
SECTIONS       := $(wildcard EpidemicsUtilities/src/0*.jl)

MONTAGE        := /usr/bin/montage -label '%f' -geometry '360x360>+1+1' 

PRODUCTS       := figures.pdf production.pdf experiment.pdf

# ====================
# Main targets
main: docs
work: $(PRODUCTS)
docs: $(DOCUMENT).pdf
verify: $(PRODUCTS) $(wildcard image/VERIFY_*.png)

# ====================
# Documents support
#
# The following translations is not yet perfect!
# It doesn't include directives "#|" in codeblocks.
$(DOCUMENT).qmd: $(BUILD)/INTERMEDIATE.jl	
	$(HOME)/.local/bin/julia -e 'using Literate; Literate.markdown("$<", name="$@", documenter=false, flavor = Literate.DocumenterFlavor(), codefence="```{julia}" => "```")'
	mv $(DOCUMENT).qmd.md $(DOCUMENT).qmd

# Concatenate ordered source files into temporary intermediate file for documentation.
$(BUILD)/INTERMEDIATE.jl: $(SOURCE) $(SECTIONS)
	@cat $(SOURCE) $(SECTIONS) > $@
	@echo $(shell date +"%-d %B %Y")
	sed -i -e's/# date: today/# date: $(shell date +"%d %B %Y")/' $@
	@echo $(SECTIONS)

# ====================
# Clean-up
clean:
	-rm $(wildcard image/.DIFF.*.png)
	-rm $(wildcard *.ipynb)
	$(HOME)/.local/bin/julia -e 'Base.compilecache(Base.identify_package("EpidemicsUtilities"))'

# ====================
# Verification
set-up-verify: ; for f in image/*.png ; do cp $$f $${f/image\//image\/VERIFY_} ; done

image/VERIFY_%.png: image/%.png
	@if /usr/bin/cmp -s $@ $<  ;                                       \
	then                                                               \
	    echo No change in image $< ;                                   \
	    touch $@ ;                                                     \
	else                                                               \
	    /usr/bin/compare $< $@ $(<D)/.diff.$(<F) ;                     \
	    $(MONTAGE) $< $(<D)/.diff.$(<F) $@ miff:- | /usr/bin/display ; \
	    rm $(<D)/.diff.$(<F) ;                                         \
	fi

# ====================
# Intermediate files
.INTERMEDIATE: $(BUILD)/INTERMEDIATE.jl

# ====================
# Automatic conversion of qmd to pdf
%.pdf: %.qmd $(UTILITIES) ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)
