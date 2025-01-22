# Makefile for ~/ms/PerfectEpidemics/julia
SHELL           := /usr/bin/bash
LOCATION        := $(shell pwd)

PRODUCTS        := figures.qmd production.pdf introduction.pdf check.pdf test.pdf LFEandNFZ.pdf CFTP.pdf CFTP-demo.pdf

CSL             := $(HOME)/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl

QUARTO          := /usr/local/bin/quarto
QUARTO_CACHE    ?=  --no-cache
#                   --cache-refresh
#                   --cache

QUARTO_OPTIONS  :=  --csl=$(CSL) $(QUARTO_CACHE)
#QUARTO_OPTIONS  :=  $(QUARTO_CACHE)

JULIA           := $(HOME)/.juliaup/bin/julia

MONTAGE         := /usr/bin/montage -label '%f' -geometry '360x360>+1+1' 

START           := xdg-open

.PHONY: main verify verify-image verify-image verify-animation reset-verify-image \
	verify-animation reset-verify-image reset-verify-animation listings list  \
	clean install movie animation 

# ====================
# Main targets
main: $(PRODUCTS)
verify: main verify-image verify-animation

# ====================
# list all targets
list:
	@grep '^[^#[:space:]].*:' Makefile

# ====================
# Clean-up
clean:
	-rm -f $(wildcard *.ipynb)
	-rm -Rf .jupyter_cache
	$(JULIA) -e 'import EpidemicsCFTP'
	$(JULIA) -e 'Base.compilecache(Base.identify_package("EpidemicsCFTP"))'
	$(JULIA) -e 'import EpidemicsUtilities'
	$(JULIA) -e 'Base.compilecache(Base.identify_package("EpidemicsUtilities"))'
	$(JULIA) -e 'import EpidemicsCFTP, EpidemicsUtilities ; \
			println(EpidemicsCFTP.summary) ; println(EpidemicsUtilities.summary)'

# ====================
# Installation
install:
	@make -C EpidemicsCFTP install
	@echo ----------
	@make -C EpidemicsUtilities install

# ====================
# Animation as MPEG: see https://trac.ffmpeg.org/wiki/Slideshow
FRATE           := 10
FPAUSE1         :=  3
FPAUSE2         := 25
movie: CFTP-demo.pdf
	ffmpeg -framerate $(FRATE) -pattern_type glob -i 'animation/demo-a*.png' \
		-vf tpad=stop_mode=clone:stop_duration=$(FPAUSE1) animate-a.mp4
	ffmpeg -framerate $(FRATE) -pattern_type glob -i 'animation/demo-b*.png' \
		-vf tpad=stop_mode=clone:stop_duration=$(FPAUSE1) animate-b.mp4
	ffmpeg -framerate $(FRATE) -pattern_type glob -i 'animation/demo-c*.png' \
		-vf tpad=stop_mode=clone:stop_duration=$(FPAUSE1) animate-c.mp4
	ffmpeg -framerate $(FRATE) -pattern_type glob -i 'animation/demo-d*.png' \
		-vf tpad=stop_mode=clone:stop_duration=$(FPAUSE1) animate-d.mp4
	ffmpeg -framerate $(FRATE) -pattern_type glob -i 'animation/demo-e*.png' \
		-vf tpad=stop_mode=clone:stop_duration=$(FPAUSE2) animate-e.mp4
	# Now merge these videos
	ffmpeg -f concat -safe 0 -i \
		<(for c in a b c d e ; do echo "file '$$PWD/animate-$$c.mp4'"; done) \
		-c copy animate.mp4
	rm animate-*.mp4
	
# ====================
# Animation as GIF
animation: animate.gif ; $(START) "$<" 2> /dev/null
%.gif: %.jl 
	$(JULIA) $<
	rm animation/script*.*

# ====================
# Verification
verify-image: $(wildcard image/VERIFY_*.png) $(wildcard animation/VERIFY_*.png)
set-up-verify-image: ; for f in image/VERIFY_*.png ; do cp $${f/VERIFY_/} $$f ; done
reset-verify-image:  ; for f in image/VERIFY_*.png ; do cp $${f/VERIFY_/} $$f ; done
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

verify-animation: $(wildcard animation/VERIFY_*.png)
set-up-verify-animation: ; for f in animation/VERIFY_*.png ; do cp $${f/VERIFY_/} $$f ; done
reset-verify-animation:  ; for f in animation/VERIFY_*.png ; do cp $${f/VERIFY_/} $$f ; done
animation/VERIFY_%.png: animation/%.png
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
listings: $(PRODUCTS) ; make --directory=PRINTING listings
	cp $(PRODUCTS) PRINTING

# --------------------
## List Makefile
include $(HOME)/lib/makefiles/listing-makefile.mak


# --------------------
# README.pdf
README.pdf: README.md ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)

# --------------------
## List configurations
%.pdf: config/%.yml
	@echo Constructing $@ from $<
	@echo "# Listing of \`$<\` for \`$(LOCATION)\`" >  $(subst .pdf,.qmd,$@)
	@echo "\`\`\`yaml"                              >> $(subst .pdf,.qmd,$@)
	@cat $<                                         >> $(subst .pdf,.qmd,$@)
	@echo "\`\`\`"                                  >> $(subst .pdf,.qmd,$@)
	$(QUARTO) render $(subst .pdf,.qmd,$@) --to pdf
	@rm $(subst .pdf,.qmd,$@)

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
