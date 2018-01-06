figures := $(wildcard image/*.png) $(wildcard image/*.jpg)
graphicsprogs := static.py static.cfg

main: DOC/epidemic.py.doctested
graphics: $(figures) 
doc: epidemic-doc.pdf README.pdf

view: docs ; xdg-open epidemic-doc.pdf

recipe1 := --title="Figure 1: an example of a Free SIR Epidemic" --logging=INFO --output=figure1a.png \
		--remove="[[1, 1.6], [1.3], [0.5, 2]]" \
		--infect="[[[0.2, 1.1, 1.5]], [[0.4, 0.9], [0.6, 1.4]]]"
recipe2 := --title="Figure 2: an example of a Free SIR Epidemic" --logging=INFO  --output=figure2a.png  \
		--remove="[[1.1, 2.0], [0.3], [0.2], [0.1], [1.0]]" \
		--infect="[[[1.9]], [[0.9], [0.1, 1.8]], [[], [], [0.3]], [[0.5], [0.6], [0.7], [1.2]]]"
recipe3 := --title="Figure 3: an example of a Free SIR Epidemic" --logging=INFO --output=figure3a.png  \
		--remove="[[1.1, 2.0], [1.5], [1.3], [1.2], [1.0]]" \
		--infect="[[[0.1]],  [[0.9], [0.1, 1.8]], [[], [1.25], [0.3]], [[0.5], [0.6, 1.4], [0.7, 1.15], [1.2]]]"
recipe4 := --title="Figure 4: a random example of a Free SIR Epidemic" --logging=INFO --output=figure4a.png \
		--seed=3 --T=4 --beta=0.2 --n=10

f1: ; python3 static.py $(recipe1)
f2: ; python3 static.py $(recipe2)
f3: ; python3 static.py $(recipe3)
f4: ; python3 static.py $(recipe4)

figure1: image/figure1.png
figure2: image/figure2.png
figure3: image/figure3.png
figure4: image/randomfigure.png

epidemic-doc.pdf: epidemic-doc.md $(figures)
	pandoc epidemic-doc.md -o epidemic-doc.pdf

README.pdf: README.md $(figure1) KEY.md TODO.md
	pandoc README.md KEY.md TODO.md -o README.pdf

KEY.md: static.cfg
	sed -e'1d' -e'2d'  -e'/^[^#\[]/d' -e's/^# *//' -e's/ ; /: /' \
	-e'/\]$$/d' -e's/\[/`/'  -e's/\]/`/' static.cfg > KEY.md
	
image/figure1.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe1) --output=$@ --forceoutput
image/figure2.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe2) --output=$@ --forceoutput
image/figure3.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe3) --output=$@ --forceoutput
image/randomfigure.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe4) --output=$@ --forceoutput

DOC/epidemic.py.doctested: epidemic.py epidemic-doc.md
	python3 epidemic.py --doctest --logging=INFO
