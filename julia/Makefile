SHELL          := /usr/bin/bash

QUARTO         := /usr/local/bin/quarto
CSL            := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
QUARTO_OPTIONS :=  --csl=$(CSL)
#QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash --csl=$(CSL)

MONTAGE        := /usr/bin/montage -label '%f' -geometry '360x360>+1+1' 

PRODUCTS       := production.pdf experiment.pdf introduction.pdf

# ====================
# Main targets
main: $(PRODUCTS)
verify: $(PRODUCTS) $(wildcard image/VERIFY_*.png)

# ====================
# Clean-up
clean:
	-rm -f $(wildcard *.ipynb)
	$(HOME)/.local/bin/julia -e 'Base.compilecache(Base.identify_package("EpidemicsUtilities"))'
	$(HOME)/.local/bin/julia -e 'Base.compilecache(Base.identify_package("EpidemicsCFTP"))'

# ====================
# Verification
set-up-verify: ; for f in image/VERIFY_*.png ; do cp $${f/VERIFY_/} $$f ; done

reset-verify: ; for f in image/VERIFY_*.png ; do cp $${f/VERIFY_/} $$f ; done

image/VERIFY_%.png: image/%.png
	@if /usr/bin/cmp -s $@ $<  ;                                       \
	then                                                               \
	    echo No change in image $< ;                                   \
	    touch $@ ;                                                     \
	else                                                               \
	    echo **Issue** in image $< ;                                       \
	    /usr/bin/compare $< $@ $(<D)/.diff.$(<F) ;                     \
	    $(MONTAGE) $< $(<D)/.diff.$(<F) $@ miff:- | /usr/bin/display ; \
	    rm $(<D)/.diff.$(<F) ;                                         \
	fi

# ====================
# Further dependencies
introduction.pdf: config/theme.yml

# ====================
# Automatic conversion of qmd to pdf
#%.pdf: %.qmd $(UTILITIES) ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS) --cache-refresh
# %.pdf: %.qmd $(UTILITIES) ; $(QUARTO) render $< -P source:$< --to pdf $(QUARTO_OPTIONS) --no-cache
%.pdf: %.qmd $(UTILITIES) ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS) --cache

# ====================
# NOTE
# To ensure `papermill` works for the -P option:
# First, in `bash`, do
# bash> pip3 install papermill
# then in `julia`, do
#  julia> ENV["JUPYTER"]=""; Pkg.build("IJulia") 
# to rebuild IJulia to use Julia's own Conda-based Jupyter, and then
# julia> using Conda; Conda.add("papermill") 
# as discussed in
# https://github.com/quarto-dev/quarto-cli/discussions/5833
