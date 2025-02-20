# Makefile for `EpidemicCFTP`
SHELL      := /usr/bin/bash
LOCATION   := $(shell pwd)
MODULE     := $(notdir $(LOCATION))

GIT        := /usr/bin/git
JULIA      := $(HOME)/.juliaup/bin/julia

PYTHON 	:= /usr/bin/python2
export PYTHONPATH=/home/wilfrid/lib/python

QUARTO     := /usr/local/bin/quarto
CSL        := /home/wilfrid/lib/pandoc/CSL/ima-journal-of-applied-mathematics.csl
src_files  := $(wildcard src/*.jl) 
doc_files  := $(wildcard docs/src/*.md) 
doc_images := docs/src/image/introduction-11-no-fly-zone.pdf \
	docs/src/image/introduction-01-key.pdf 
test_files :=$(wildcard test/*.jl)

# ========================
.PHONY: documentation html-format pdf-format view test doc_images

# ===================
# GUI STARTS HERE
# ===============
# PRIMARY TARGETS
# ===============
# Documentation
documentation: test html-format pdf-format
#  * html format
html-format: test docs/site/index.html
#  * pdf format
pdf-format:  docs/build/$(MODULE).pdf
	echo "\\setmonofont[Scale = 0.75]{JuliaMono}"        > docs/build/custom.sty
	echo "\\chapterstyle{verville}"                     >> docs/build/custom.sty
	echo "\\renewcommand{\\afterpartskip}{\\vfil}"      >> docs/build/custom.sty
	echo "\\renewcommand\\thepart{\\Alph{part}}"        >> docs/build/custom.sty
	latexmk -cd -g -xelatex -shell-escape docs/build/$(MODULE).tex
	xdg-open $<


# Serve documentation (not yet working)
view: serve
	xdg-open http://127.0.0.1:8000	

# Place documentation online (not yet working)
online: docs/build/index.md

# Listing of code
listings: README.pdf Makefile.pdf $(MODULE)-test.pdf

# ============
# Installation
install: .$(MODULE).compiled ; @touch $<
.$(MODULE).compiled: $(wildcard *.jl)
	@$(JULIA) -e 'Base.compilecache(Base.identify_package("$(MODULE)")) ; \
		import $(MODULE); println($(MODULE).summary)'
commit:
	$(GIT) commit -a
	$(GIT) push

# =======
# Testing
doctest:
	@$(JULIA) --color=yes docs/make_doctests.jl

test: .test.stamp
	@touch test.stamp

# Clean `docs/build` directory
virgin: ; rm -rf docs/build/*
# ===================
# GUI ENDS HERE

# ----------------------------------------------
# Automatic help (prints this helptext, or uses gui):
help: ; $(PYTHON) "$(PYTHONPATH)/make/browser.py"
gui: ; $(PYTHON) "$(PYTHONPATH)/make/browser.py" --gui


serve: documentation
	pushd docs ; mkdocs serve

# ----------------------------------------------
# List test source: target is `$(MODULE)-test.pdf`
include $(HOME)/lib/makefiles/listing-makefile.mak

		
# ====================
# Arrangements
docs/src/image/%.pdf: ../image/%.pdf 
	cp $< docs/src/image 

serve: SHELL:=/bin/bash 
docs/site/index.html: docs/build/index.md



$(MODULE)-test.pdf: $(MODULE)-test.qmd
	$(QUARTO) render $< --to pdf
	rm $<
$(MODULE)-test.qmd: $(test_files)
	@echo "# Unit tests for module \`$(MODULE)\`"                            > $(MODULE)-test.qmd
	@echo "\`\`\`{julia}"							>> $(MODULE)-test.qmd
	@echo "#| echo: false"							>> $(MODULE)-test.qmd
	@echo "import $(MODULE): date, version" 				>> $(MODULE)-test.qmd
	@echo "println(\"$(MODULE) version \$$version, compiled on \$$date\")"	>> $(MODULE)-test.qmd
	@echo "\`\`\`"      							>> $(MODULE)-test.qmd
	@for f in $(test_files) ; do                           \
		echo "## File \`$$f\`" >> $(MODULE)-test.qmd ; \
		echo "\`\`\`julia"     >> $(MODULE)-test.qmd ; \
		cat $$f                >> $(MODULE)-test.qmd ; \
		echo "\`\`\`"          >> $(MODULE)-test.qmd ; \
	done

# ========================
# README.pdf
README.pdf: README.md ; $(QUARTO) render $< --to pdf $(QUARTO_OPTIONS)

# ========================

.test.stamp: $(src_files) $(test_files)
	@$(JULIA) --color=yes test/00-runtests.jl

docs/build/index.md: $(src_files) $(doc_files) $(doc_images)
	@$(JULIA) --color=yes docs/make.jl

docs/build/$(MODULE).tex: $(doc_files) $(src_files) $(doc_images)
	@$(JULIA) --color=yes docs/make_latex.jl

# Needs pygments for python
docs/build/$(MODULE).pdf: docs/build/$(MODULE).tex
	cd docs/build ; \
	latexmk -f -interaction=nonstopmode -view=none -lualatex -shell-escape $(notdir $<)
