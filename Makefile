# Makefile for `EpidemicCFTP`

JULIA := $(HOME)/.julia/julia-current/bin/julia

package    := $(notdir $(shell pwd))

src_files  := $(wildcard src/*.jl) 
doc_files  := $(wildcard docs/src/*.md) 
test_files :=$(wildcard test/*.jl)

# ========================

.PHONY: documentation view test

documentation: test docs/site/index.html

view-pdf: docs/build/$(package).pdf
	xdg-open $<

view: serve
	xdg-open http://127.0.0.1:8000	

serve: documentation
	pushd docs ; mkdocs serve
	
test: tested.stamp
	@touch tested.stamp

virgin: ; rm -rf docs/build/*
	
# ========================

tested.stamp: $(src_files) $(test_files)
	@$(JULIA) --color=yes test/runtests.jl

docs/build/index.md: $(src_files) $(doc_files)
	@$(JULIA) --color=yes docs/make.jl

docs/build/$(package).tex: $(doc_files) $(src_files)
	@$(JULIA) --color=yes docs/make_latex.jl

# Needs DocumenterLaTeX for julia
#       pygments for python
docs/build/$(package).pdf: docs/build/$(package).tex
	cd docs/build ; \
	latexmk -f -interaction=nonstopmode -view=none -lualatex -shell-escape $(notdir $<)


serve: SHELL:=/bin/bash 
docs/site/index.html: docs/build/index.md


