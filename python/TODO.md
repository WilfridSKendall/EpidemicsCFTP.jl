
Still to be done
----------------

### Paper:
 - Complete proof of monotonicity.
 - Illustrate using images produced by `python3` code.
 - Can monotonicity extend to variation of parameters (eg infectivity parameter)?
 - Can anything be done with non-exponential infective periods?
 - More general compartment models?

### Coding:
 - **DONE:** Colour-code potential infections according to whether or not they are active.
 - Introduce conditioned observed removals(!).
 - **DONE:** Compute Mordor, no-fly zone
 - Compute last feasible infections.
 - Produce a dynamic version, which updates according to our algorithm using a new `Innovations` instance which possesses an `update` method.
 - Check monotonicity using many random runs.
 - Implement _CFTP_.
 - Omnithermal _CFTP_?
 - Estimation of parameters?
 - What about rates of infection that vary with time, or non-linearly with total number of susceptibles?

 
