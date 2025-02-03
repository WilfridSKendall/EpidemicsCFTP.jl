# Perfect Epidemics
## Seminar at Warwick University Department of Statistics
## Wilfrid S Kendall
### 3 February 2025

## Abstract:
This talk reports on some work I am engaged on with [Stephen Connor](https://www-users.york.ac.uk/~sbc502), concerning a perfect simulation approach for making exact draws from an SIR epidemic when one observes only the removal times.

**Keywords:** Coupling from the Past (CFTP); Dead Leaves; Epidemics; Exact Simulation; Markov Chain Monte Carlo; Multiserver Queues; Perfect Simulation.

**Acknowledgments:** The author acknowledges support of UK EPSRC grant EP/R022100.

{{< pagebreak >}}

------

## Invocation details

**(A)** to construct {==the talk, together with the handout and notes,==} use (respectively)

```bash
make
make handout
make notes
```

or (to make everything)

```bash
make full
```

which includes making a PDF of this `README` file.

------

**(B)** the {==talk handout==} is located at  
<https://wilfridskendall.github.io/talks/PerfectEpidemics/PerfectEpidemics-handout.pdf>.  
Generate the {==QR code==} for the handout (as a `PNG` file) by

```bash
qrencode -s 3 -l H -o "image/talk_URL.png" \
"https://wilfridskendall.github.io/talks/PerfectEpidemics/PerfectEpidemics-handout.pdf"
```

which itself is invoked by `make qrcode`: 
`qrcode`is a subtarget for the `make` invocations in **(A)** above.

------

**(C)** {==to place PDFs on the Github website==}, use

```bash
make web
```

 (*via* `make deploy` in `~/HTML/WilfridSKendall`).


