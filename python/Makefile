figures := $(wildcard image/*.png)

main: DOCS/epidemic.py.doctested

randomfigure: static.py epidemic.py
	echo $(figures)
	python3 static.py --seed=3 --T=5 --n=10

figure1: static.py epidemic.py
	echo $(figures)
	python3 static.py \
		--remove="[[1, 1.6], [1.3], [0.5, 2]]" \
		--infect="[[[0.4, 0.9], [0.6, 1.4]], [[0.2, 1.1, 1.5]]]"


figure2: static.py epidemic.py
	echo $(figures)
	python3 static.py \
		--remove="[[1.0], [0.1], [0.2], [0.3], [1.1, 2.0]]" \
		--infect="[[[0.5], [0.6], [0.7], [1.2]], [[], [], []], [[0.9], [1.8]], [[1.9]]]"


figure3: static.py epidemic.py
	echo $(figures)
	python3 static.py \
		--remove="[[1.0], [1.2], [1.3], [1.5], [1.1, 2.0]]" \
		--infect="[[[0.5], [0.6], [0.7], [1.2]], [[], [], []], [[0.9], [1.8]], [[0.1]]]"


DOCS/epidemic.py.doctested: epidemic.py DOCS/epidemic.txt
	python3 epidemic.py --doctest --logging=INFO
