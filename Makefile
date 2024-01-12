# Makefile for `EpidemicCFTP`
SHELL      := /usr/bin/bash
LOCATION   := $(shell pwd)
MODULE     := $(notdir $(LOCATION))

GIT   := /usr/bin/git
JULIA := $(HOME)/.julia/julia-current/bin/julia

QUARTO     := /usr/local/bin/quarto


src_files  := $(wildcard src/*.jl) 
doc_files  := $(wildcard docs/src/*.md) 
doc_images := docs/src/image/introduction-18-one-iteration.pdf \
	docs/src/image/introduction-01-key.pdf 
test_files :=$(wildcard test/*.jl)

# ========================
.PHONY: documentation view test doc_images

documentation: test docs/site/index.html

view-pdf: docs/build/$(MODULE).pdf
	echo "\\setmonofont[Scale = 0.75]{JuliaMono}"        > docs/build/custom.sty
	echo "\\chapterstyle{verville}"                     >> docs/build/custom.sty
	echo "\\renewcommand{\\afterpartskip}{\\vfil}"      >> docs/build/custom.sty
	echo "\\renewcommand\\thepart{\\Alph{part}}"        >> docs/build/custom.sty
	latexmk -cd -g -xelatex -shell-escape docs/build/$(MODULE).tex
	xdg-open $<

view: serve
	xdg-open http://127.0.0.1:8000	

serve: documentation
	pushd docs ; mkdocs serve

online: docs/build/index.md
	
doctest:
	@$(JULIA) --color=yes docs/make_doctests.jl

test: .test.stamp
	@touch test.stamp

virgin: ; rm -rf docs/build/*

# ====================
# Installation
install:
	@touch src/$(MODULE).jl
	@$(JULIA) -e 'Base.compilecache(Base.identify_package("$(MODULE)")) ; \
		import $(MODULE); println($(MODULE).summary)'
commit:
	$(GIT) commit -a
	$(GIT) push
		
		
# ====================
# Arrangements
docs/src/image/%.pdf: ../image/%.pdf 
	cp $< docs/src/image 

serve: SHELL:=/bin/bash 
docs/site/index.html: docs/build/index.md



# ====================
# List test source: target is `$(MODULE)-test.pdf`
include $(HOME)/lib/makefiles/listing-makefile.mak
listings: README.pdf Makefile.pdf $(MODULE)-test.pdf
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

# Needs DocumenterLaTeX for julia
#       pygments for python
docs/build/$(MODULE).pdf: docs/build/$(MODULE).tex
	cd docs/build ; \
	latexmk -f -interaction=nonstopmode -view=none -lualatex -shell-escape $(notdir $<)
