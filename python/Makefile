figures := $(wildcard image/*.png)

main: innovate.py.doctested

figure1: gr-static.py innovate.py
	echo $(figures)
	python3 gr-static.py

innovate.py.doctested: innovate.py innovate.txt ; python3 innovate.py --doctest --logging=INFO
