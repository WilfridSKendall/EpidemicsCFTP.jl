





![pI-lo](image/inline-pI-lo.png "pI-lo")_____`pI-lo`: putative infection circumstances (thin pale green arrow, running from putative infecting row to row that would be infected).

For this infection actually to happen, the putative infecting row must be infected at the time of the
infection, and the row to be infected must be the lowest row susceptible at time of infection.

![lI](image/inline-lI.png "lI")_____`lI`: locates latent infection (as a yellow circle with orange boundary on row that would be infected).

![lIc](image/inline-lIc.png "lIc")_____`lIc`: latent infection circumstances (thin dark green arrow, running from latent previously highest infected to new latent highest infected).

For this infection actually to happen, the putative infecting row must be infected at the time of the
infection, and the row to be infected must be the lowest row susceptible at time of infection.

![aI](image/inline-aI.png "aI")_____`aI`: activated infection (thick yellow arrow, running from previously highest infected to new highest infected).

For this infection actually to happen, the putative infecting row must be infected at the time of the
infection, and the row to be infected must be the lowest row susceptible at time of infection.

![Infectious](image/inline-Infectious.png "Infectious")_____`Infectious`: portions of rows that are infected (yellow lines).

![Epidemic](image/inline-Epidemic.png "Epidemic")_____`Epidemic`: traces most recently infected individual that is currently infected (as a thin red line).

![pR](image/inline-pR.png "pR")_____`pR`: putative removal (blue no-way sign).

For this removal actually to take effect, the row on which it sits must be infected at the relevant time.
The lowest row currently infected will then suffer a removal.

![R](image/inline-R.png "R")_____`R`: implemented removal (red no-way sign).

This sits on the lowest row currently infected, which then suffers a removal;
it sits below the corresponding potential removal. Note that sometimes potential and
implemented removals coincide, in which case in the initial configuration of `static.py`
only the implemented removal is visible.

![Mordor](image/inline-Mordor.png "Mordor")_____`Mordor`: to avoid premature removal, these black portions of rows should not be infected.

![nofly](image/inline-nofly.png "nofly")_____`nofly`: to avoid premature removal, these grey portions of rows should not be infected.
