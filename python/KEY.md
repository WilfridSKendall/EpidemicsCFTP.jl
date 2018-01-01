





`11-pI`: locates potential infection (as a yellow circle with orange boundary on row that would be infected).

`11-pI-lo`: potential infection (wide lightgreen arrow, running from putative infecting row to row that would be infected).

For this infection actually to happen, the putative infecting row must be infected at the time of the
infection, and the row to be infected must be the lowest row susceptible at time of infection.

`12-Infectious`: portions of rows that are infected (yellow lines).

`12-Epidemic`: traces most recently infected individual that is currently infected (as a thin red line).

`11-pR`: potential removal (blue no-way sign).

For this removal actually to take effect, the row on which it sits must be infected at the relevant time.
The lowest row currently infected will then suffer a removal.

`12-R`: implemented removal (red no-way sign).

This sits on the lowest row currently infected, which then suffers a removal;
it sits below the corresponding potential removal. Note that sometimes potential and
implemented removals coincide, in which case in the initial configuration of `static.py`
only the implemented removal is visible.
