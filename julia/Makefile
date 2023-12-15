# Makefile for ~/ms/PerfectEpidemics/julia
SHELL           := /usr/bin/bash
LOCATION        := $(shell pwd)

PRODUCTS        := production.pdf introduction.pdf check.pdf test.pdf

CSL             := $(HOME)/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl

QUARTO          := /usr/local/bin/quarto
 QUARTO_CACHE   :=  --cache-refresh
#QUARTO_CACHE   :=  --no--cache
#QUARTO_CACHE   :=  --cache
 QUARTO_OPTIONS :=  --csl=$(CSL) $(QUARTO_CACHE)
JULIA           := $(HOME)/.local/bin/julia

MONTAGE         := /usr/bin/montage -label '%f' -geometry '360x360>+1+1' 

# ====================
# Main targets
main: $(PRODUCTS)
verify: $(PRODUCTS) $(wildcard image/VERIFY_*.png)

# ====================
# Clean-up
clean:
	-rm -f $(wildcard *.ipynb)
	-rm -Rf .jupyter_cache
	$(JULIA) -e 'import EpidemicsCFTP'
	$(JULIA) -e 'Base.compilecache(Base.identify_package("EpidemicsCFTP"))'
	$(JULIA) -e 'import EpidemicsUtilities'
	$(JULIA) -e 'Base.compilecache(Base.identify_package("EpidemicsUtilities"))'

# ====================
# Installation
install:
	@make -C EpidemicsCFTP install
	@echo ----------
	@make -C EpidemicsUtilities install
	@echo ----------
	$(JULIA) -e 'import EpidemicsCFTP: version      ; println(version)'
	$(JULIA) -e 'import EpidemicsUtilities: version ; println(version)'

# ====================
# Verification
set-up-verify: ; for f in image/VERIFY_*.png ; do cp $${f/VERIFY_/} $$f ; done

reset-verify:  ; for f in image/VERIFY_*.png ; do cp $${f/VERIFY_/} $$f ; done

image/VERIFY_%.png: image/%.png
	@if /usr/bin/cmp -s $@ $<  ;                                       \
	then                                                               \
	    echo No change in $< ;                                         \
	    touch $@ ;                                                     \
	else                                                               \
	    echo **Issue** in $< ;                                         \
	    /usr/bin/compare $< $@ $(<D)/.diff.$(<F) ;                     \
	    $(MONTAGE) $< $(<D)/.diff.$(<F) $@ miff:- | /usr/bin/display ; \
	    rm $(<D)/.diff.$(<F) ;                                         \
	fi

# ====================
# Creating PDFs of listings in `PRINTING` directory
listings: listings-current listings-EpidemicsCFTP listings-EpidemicsUtilities
listings-current: Makefile.pdf
	mv Makefile.pdf PRINTING
listings-EpidemicsCFTP: 
	make --directory=EpidemicsCFTP Makefile.pdf EpidemicsCFTP-test.pdf
	mv EpidemicsCFTP/Makefile.pdf PRINTING/EpidemicsCFTP-Makefile.pdf
	mv EpidemicsCFTP/EpidemicsCFTP-test.pdf PRINTING
listings-EpidemicsUtilities: 
	make --directory=EpidemicsUtilities Makefile.pdf EpidemicsUtilities-test.pdf
	mv EpidemicsUtilities/Makefile.pdf PRINTING/EpidemicsUtilities-Makefile.pdf
	mv EpidemicsUtilities/EpidemicsUtilities-test.pdf PRINTING

# --------------------
## List Makefile
include $(HOME)/lib/makefiles/listing-makefile.mak

# ====================
# Further dependencies
introduction.pdf: config/theme.yml

# ====================
# Automatic conversion of qmd to pdf
# --cache-refresh seems to be good at loading modules anew.
%.pdf: %.qmd $(UTILITIES) ; @echo "Creating $@" ; \
	$(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)

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
