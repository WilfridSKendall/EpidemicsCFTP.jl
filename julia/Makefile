QUARTO := /usr/local/bin/quarto
QUARTO_OPTIONS :=  --from=markdown+tex_math_single_backslash

figures.pdf: figures.qmd
	$(QUARTO) render $^ render --to pdf $(QUARTO_OPTIONS)

clean: ; rm figures.ipynb
