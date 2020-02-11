





----

![pI-lo](image/inline-pI-lo.png){ width=100 } illustrates tag ending `pI-lo`: putative infection circumstances (thin pale green arrow, running from putative infecting row to row that would be infected).

For this infection actually to happen, the putative infecting row must be infected at the time of the
infection, and the row to be infected must be the lowest row susceptible at time of infection.

----

![lI](image/inline-lI.png){ width=100 } illustrates tag ending `lI`: locates latent infection (as a yellow circle with orange boundary on row that would be infected).

----

![lIc](image/inline-lIc.png){ width=100 } illustrates tag ending `lIc`: latent infection circumstances (thin dark green arrow, running from latent previously highest infected to new latent highest infected).

For this infection actually to happen, the putative infecting row must be infected at the time of the
infection, and the row to be infected must be the lowest row susceptible at time of infection.

----

![aI](image/inline-aI.png){ width=100 } illustrates tag ending `aI`: activated infection (thick yellow arrow, running from previously highest infected to new highest infected).

For this infection actually to happen, the putative infecting row must be infected at the time of the
infection, and the row to be infected must be the lowest row susceptible at time of infection.

----

![Infectious](image/inline-Infectious.png){ width=100 } illustrates tag ending `Infectious`: portions of rows that are infected (yellow lines).

----

![Epidemic](image/inline-Epidemic.png){ width=100 } illustrates tag ending `Epidemic`: traces most recently infected individual that is currently infected (as a thin red line).

----

![pR](image/inline-pR.png){ width=100 } illustrates tag ending `pR`: putative removal (blue no-way sign).

For this removal actually to take effect, the row on which it sits must be infected at the relevant time.
The lowest row currently infected will then suffer a removal.

----

![R](image/inline-R.png){ width=100 } illustrates tag ending `R`: implemented removal (red no-way sign).

This sits on the lowest row currently infected, which then suffers a removal;
it sits below the corresponding potential removal. Note that sometimes potential and
implemented removals coincide, in which case in the initial configuration of `static.py`
only the implemented removal is visible.

----

![Mordor](image/inline-Mordor.png){ width=100 } illustrates tag ending `Mordor`: to avoid premature removal, these black portions of rows should not be infected.

----

![nofly](image/inline-nofly.png){ width=100 } illustrates tag ending `nofly`: to avoid premature removal, these grey portions of rows should not be infected.

----

![West](image/inline-West.png){ width=100 } illustrates tag ending `West`: infection must occur before these orange portions of rows if removals are to be unchanged.

----

![lvI](image/inline-lvI.png){ width=100 } illustrates tag ending `lvI`: last viable infection times are indicated by pink arrows. Note that in case infection occurs at time `0`, then this is deemed to be the last viable infection time!

