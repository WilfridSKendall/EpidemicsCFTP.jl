Prerequisites
=============
These programs are `python3` scripts, so `python3` is required. 

They also use the `Tkinter` and `Image` modules, while `Pandoc` is used to render documentation.
In `Ubuntu` use the following on the command-line:

    sudo apt-get install pandoc python3-tk python3-pil

I belive these are all that is required.
 
Testing FreeEpidemic
====================
Basic documentation
-------------------
Here are simple invocations of the `FreeEpidemic` and `Innovations` classes:

     >>> from pprint import pprint
     >>> from epidemic import Innovations, FreeEpidemic
     
     >>> iv = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                  infect=[[[0.2, 1.1, 1.5]],
     ...                          [[0.4, 0.9], [0.6, 1.4]]
     ...                         ])

Note the form of the `Innovations` structure:

     >>> print(iv)
     Innovations for SIR epidemic on 3 individuals:
     Row               List of proposed potential removals
       3:              0.50 2.00
       2:              1.30
       1:              1.00 1.60
     Target row
          (Origin)     List of proposed potential infections
       3:   (2)        0.60 1.40
            (1)        0.40 0.90
       2:   (1)        0.20 1.10 1.50

     >>> epidemic = FreeEpidemic(innovations=iv)
     >>> print(epidemic(pretty=True))  
     Time    S, I, R
     0.00   (2, 1, 0)
     0.20   (1, 2, 0)
     0.40   (0, 3, 0)
     0.50   (0, 2, 1)
     1.30   (0, 1, 2)
     2.00   (0, 0, 3)

![A graphical illustration of the resulting free SIR epidemic](image/figure1.png "Free epidemic")


Using `static.py`
-----------------
The program `static.py` produces a visual display of the epidemic.
Here is the invocation which produced the window shown in the screenshot:

	python3 static.py --title="Figure 1: an example of a Free SIR Epidemic" \
		--output=figure1a.png \
		--remove="[[1, 1.6], [1.3], [0.5, 2]]" \
		--infect="[[[0.2, 1.1, 1.5]], [[0.4, 0.9], [0.6, 1.4]]]"

Note the data format for the `remove` and `infect` lines. 
These define an `Innovations` instance, which is effectively
a list of two sub-lists. The first sub-list is the `remove`
list, containing `n` sub-sub-lists, one for each timeline row,
working from row `1` up to row `n` as per algorithm described
in the paper. Each such sub-sub-list is an ordered list of potential
removal times, the mark for each of these removals being implied by
the row corresponding to the sub-sub-list.

The second sub-list is the `infect` sub-list, containing `n-1`
sub-sub-lists. Each of these sub-sub-lists corresponds to a timeline
row starting at row `2` and working up to row `n`, and contains
sub-sub-sub-lists of potential infection times, one sub-sub-sub-list
corresponding to each row _below_ the timeline row corresponding to
the relevant sub-sub-list.

Other examples can be found in `Makefile`.
(You can access these simply using `make f1` or `f2` or `f3` or `f4`.)

![Screenshot of a version of `static.py`](image/static.jpg "static.jpg")

The colour coding in the screenshot is described in `static.cfg`: here is the description as of 20 December 2017.

`Infect-P`; potential infection (wide lightgreen arrow, running from putative infecting row to row that would be infected).
For this infection actually to happen, the putative infecting row must be infected at the time of the
infection, and the row to be infected must be the lowest row susceptible at time of infection.

`Infect`; locates the actual potential infection (as a yellow circle with orange boundary on row that would be infected).

`Infectious` ; portions of rows that are infected (yellow lines).

`Epidemic`; traces most recently infected individual that is currently infected (as a thin red line).

`Remove-P`; potential removal (blue no-way sign).
For this removal actually to take effect, the row on which it sits must be infected at the relevant time.
The lowest row currently infected will then suffer a removal.
foreground: blue

`Remove`; implemented removal (red no-way sign).
This sits on the lowest row currently infected, which then suffers a removal;
it sits below the corresponding potential removal. Note that sometimes potential and
implemented removals coincide, in which case in the initial configuration of 'static.py'
only the implemented removal is visible.

Depress one of the group of six buttons at the bottom left of the window
in order to toggle disappearance (and then appearance) of the corresponding
elements in the image. This is useful for checking the image against the
commandline specification, as well as clarifying the elements of more complicated images.
Note that reinstated elements are placed at the top layer of the image; this means that
a double-click will make the relevant elements more prominent.

Still to be done:
-----------------

* Paper:
 - Complete proof of monotonicity.
 - Illustrate using images produced by _python3_ code.
 - Can monotonicity extend to variation of parameters (eg infectivity parameter)?
 - Can anything be done with non-exponential infective periods?
 - More general compartment models?
* Coding:
 - Colour-code potential infections according to whether or not they are active.
 - Introduce conditioned observed removals(!).
 - Compute Mordor, no-fly zone, and last feasible infections.
 - Produce a dynamic version, which updates according to our algorithm using a new `Innovations` instance.
 - Check monotonicity using many random runs.
 - Implement _CFTP_.
 - Omnithermal _CFTP_?
 - Estimation of parameters?
 - What about rates of infection that vary with time, or non-linearly with total number of susceptibles?

 