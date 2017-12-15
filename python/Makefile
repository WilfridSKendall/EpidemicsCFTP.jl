figures := $(wildcard DOC/image/*.png)

main: DOC/epidemic.py.doctested
graphics: $(figures) 
docs: epidemic-doc.pdf

view: docs ; xdg-open epidemic-doc.pdf

figure1: DOC/image/figure1.png
figure2: DOC/image/figure2.png
figure3: DOC/image/figure3.png
randomfigure: DOC/image/randomfigure.png

epidemic-doc.pdf: DOC/epidemic.txt $(figures)
	pandoc DOC/epidemic.txt -o epidemic-doc.pdf

DOC/image/figure1.png: static.py epidemic.py
	-python3 static.py --title="Figure 1: an example of a Free SIR Epidemic" \
		--output=$@  --forceoutput \
		--remove="[[1, 1.6], [1.3], [0.5, 2]]" \
		--infect="[[[0.4, 0.9], [0.6, 1.4]], [[0.2, 1.1, 1.5]]]"


DOC/image/figure2.png: static.py epidemic.py
	-python3 static.py --title="Figure 2: an example of a Free SIR Epidemic" \
		--output=$@ --forceoutput  \
		--remove="[[1.0], [0.1], [0.2], [0.3], [1.1, 2.0]]" \
		--infect="[[[0.5], [0.6], [0.7], [1.2]], [[], [], []], [[0.9], [1.8]], [[1.9]]]"


DOC/image/figure3.png: static.py epidemic.py
	-python3 static.py --title="Figure 3: an example of a Free SIR Epidemic" \
		--output=$@ --forceoutput  \
		--remove="[[1.0], [1.2], [1.3], [1.5], [1.1, 2.0]]" \
		--infect="[[[0.5], [0.6], [0.7], [1.2]], [[], [], []], [[0.9], [1.8]], [[0.1]]]"

DOC/image/randomfigure.png: static.py epidemic.py
	-python3 static.py --title="Figure 1: a random example of a Free SIR Epidemic" \
		--output=$@ --forceoutput \
		--seed=3 --T=5 --n=10


DOC/epidemic.py.doctested: epidemic.py DOC/epidemic.txt
	python3 epidemic.py --doctest --logging=INFO
