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

inlineBIG := --logging=INFO --height=720 --width=1024 --T=1.5 \
		--remove="[[], [], [0.02, 0.6, 0.7, 1.3], [0.4], [1.0, 1.2, 1.3, 1.4]]" \
		--infect="[[[0.2]], [[], [0.5]], [[0.15, 0.45], [], [0.8]], [[], [], [], [1.1]]]"
		
inline := --logging=INFO --height=180 --width=256 --T=1.5 \
		--remove="[[], [], [0.02, 0.6, 0.7, 1.3], [0.4], [1.0, 1.2, 1.3, 1.4]]" \
		--infect="[[[0.2]], [[], [0.5]], [[0.15, 0.45], [], [0.8]], [[], [], [], [1.1]]]"
		
		
f1: ; python3 static.py $(recipe1)
f2: ; python3 static.py $(recipe2)
f3: ; python3 static.py $(recipe3)
f4: ; python3 static.py $(recipe4)
f5: ; python3 static.py $(recipe4) --initial=3

inlineimages: $(wildcard image/inline-*.png)

$(wildcard image/inline-*.png): static.py static.cfg 

image/inline-1.png: ; python3 static.py $(inlineBIG)       --title="All graphics elements together" --output=$@ --forceoutput
image/inline-pI-lo.png: ; python3 static.py $(inline)      --title="pI-lo graphics elements" --output=$@ --on='pI-lo' --notext --forceoutput 
image/inline-pR.png: ; python3 static.py $(inline)         --title="pR graphics elements" --output=$@ --on='pR' --notext --forceoutput 
image/inline-lI.png: ; python3 static.py $(inline)         --title="lI graphics elements" --output=$@ --on='lI' --notext --forceoutput 
image/inline-lIc.png: ; python3 static.py $(inline)        --title="lIc graphics elements" --output=$@ --on='lIc' --notext --forceoutput 
image/inline-aI.png: ; python3 static.py $(inline)         --title="sI graphics elements" --output=$@ --on='aI' --notext --forceoutput 
image/inline-Epidemic.png: ; python3 static.py $(inline)   --title="Infectious graphics elements" --output=$@ --on='Epidemic' --notext --forceoutput 
image/inline-Infectious.png: ; python3 static.py $(inline) --title="Infectious graphics elements" --output=$@ --on='Infectious' --notext --forceoutput 
image/inline-R.png: ; python3 static.py $(inline)          --title="R graphics elements" --output=$@ --on='R' --notext --forceoutput
image/inline-Mordor.png: ; python3 static.py $(inline)     --title="Mordor graphics elements" --output=$@ --on='Mordor' --notext --forceoutput
image/inline-nofly.png: ; python3 static.py $(inline)      --title="nofly" --output=$@ --on='nofly' --notext --forceoutput
image/inline-West.png: ; python3 static.py $(inline)       --title="West" --output=$@ --on='West' --notext --forceoutput
image/inline-lvI.png: ; python3 static.py $(inline)       --title="West" --output=$@ --on='lvI' --notext --forceoutput

figure1: image/figure1.png
figure2: image/figure2.png
figure3: image/figure3.png
figure4: image/randomfigure1.png
figure5: image/randomfigure2.png

epidemic-doc.pdf: epidemic-doc.md $(figures)
	pandoc epidemic-doc.md -o epidemic-doc.pdf

README.pdf: README.md $(figure1) KEY.md TODO.md
	pandoc README.md KEY.md TODO.md -o README.pdf

KEY.md: static.cfg Makefile
	sed -e'1d' -e'2d'  -e'/^[^#\[]/d' -e's/^# *//' -e's/ ; /: /' \
	-e'/\]$$/d' -e's/\[..-\(.*\)\]/----\n\n!\[\1\](image\/inline-\1.png){width=100} illustrates tag ending \`\1\`/' static.cfg > KEY.md

# KEY.md: static.cfg
# 	sed -e'1d' -e'2d'  -e'/^[^#\[]/d' -e's/^# *//' -e's/ ; /: /' \
# 	-e'/\]$$/d' -e's/\[/`/'  -e's/\]/`/' static.cfg > KEY.md
	
image/figure1.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe1) --output=$@ --forceoutput
image/figure2.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe2) --output=$@ --forceoutput
image/figure3.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe3) --output=$@ --forceoutput
image/randomfigure1.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe4) --output=$@ --forceoutput
image/randomfigure2.png: $(graphicsprogs) epidemic.py Makefile
	-python3 static.py $(recipe4) --initial=3 --output=$@ --forceoutput

DOC/epidemic.py.doctested: epidemic.py epidemic-doc.md
	python3 epidemic.py --doctest --logging=INFO
