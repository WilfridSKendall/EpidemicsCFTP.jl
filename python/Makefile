figures := $(wildcard image/*.png)

main: DOCS/epidemic.py.doctested

figure1: static.py epidemic.py
	echo $(figures)
	python3 static.py --seed=2 --T=3 --n=10

epidemic.py.doctested: epidemic.py epidemic.txt ; python3 epidemic.py --doctest --logging=INFO
