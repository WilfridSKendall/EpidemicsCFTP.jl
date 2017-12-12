figures := $(wildcard image/*.png)

main: epidemic.py.doctested

figure1: static.py epidemic.py
	echo $(figures)
	python3 static.py

epidemic.py.doctested: epidemic.py epidemic.txt ; python3 epidemic.py --doctest --logging=INFO
