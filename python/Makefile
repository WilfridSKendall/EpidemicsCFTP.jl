figures := $(wildcard image/*.png)
graphicsprogs := static.py static.cfg

main: DOC/epidemic.py.doctested
graphics: $(figures) 
doc: epidemic-doc.pdf README.pdf

view: docs ; xdg-open epidemic-doc.pdf

figure1: image/figure1.png
figure2: image/figure2.png
figure3: image/figure3.png
figure4: image/randomfigure.png

epidemic-doc.pdf: epidemic-doc.md $(figures)
	pandoc epidemic-doc.md -o epidemic-doc.pdf

README.pdf: README.md $(figure1)
	pandoc README.md -o README.pdf

image/figure1.png: $(graphicsprogs) epidemic.py
	-python3 static.py --title="Figure 1: an example of a Free SIR Epidemic" \
		--output=$@  --forceoutput \
		--remove="[[1, 1.6], [1.3], [0.5, 2]]" \
		--infect="[[[0.4, 0.9], [0.6, 1.4]], [[0.2, 1.1, 1.5]]]"


image/figure2.png: $(graphicsprogs) epidemic.py
	-python3 static.py --title="Figure 2: an example of a Free SIR Epidemic" \
		--output=$@ --forceoutput  \
		--remove="[[1.0], [0.1], [0.2], [0.3], [1.1, 2.0]]" \
		--infect="[[[0.5], [0.6], [0.7], [1.2]], [[], [], []], [[0.9], [1.8]], [[1.9]]]"


image/figure3.png: $(graphicsprogs) epidemic.py
	-python3 static.py --title="Figure 3: an example of a Free SIR Epidemic" \
		--output=$@ --forceoutput  \
		--remove="[[1.0], [1.2], [1.3], [1.5], [1.1, 2.0]]" \
		--infect="[[[0.5], [0.6], [0.7], [1.2]], [[], [], []], [[0.9], [1.8]], [[0.1]]]"

image/randomfigure.png: $(graphicsprogs) epidemic.py
	-python3 static.py --title="Figure 1: a random example of a Free SIR Epidemic" \
		--output=$@ --forceoutput \
		--seed=3 --T=5 --n=10

DOC/epidemic.py.doctested: epidemic.py epidemic-doc.md
	python3 epidemic.py --doctest --logging=INFO
