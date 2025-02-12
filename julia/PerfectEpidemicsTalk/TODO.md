##  TODO list for Perfect Epidemics 
###  3 February 2025 (was 17 January 2025)

- [x] Examples: clean up code producing innovations
- [x] Discuss with Simon Spencer
  - [ ] Read papers suggested by Simon
  - [ ] Add supporting literature for inference, as discussed with Simon
  - [ ] Follow-up further on Paul Jenkins' remarks concerning links to "look-down" representation. I don't think there is a big thing here, but need to tie it down
  - [ ] Check out @BallNeal-2025b.
- [x] Differentiate graphical representation of each C from the point where it has effect
- [ ] Use better running example (need more action in the centre of the time-scale)
- [ ] What about compartment models:
  - [ ] Case of two compartments?
  - [ ] **Each individual in its own compartment?**
    - [x] Focus on LFE and NFZ
      - [x] NFZ seems straightforward to design, but monotonicity may be challenging of course
      - [x] LFE can't be defined as trajectory! Perhaps first compute number of different paths infecting each incident? 
      - [ ] There is an issue with monotonicity for LFE: see the three-compartment counterexample in the talk Appendix C. {==Would crossover help here?==}
      - [ ] Study Gareth Roberts' remarks on "occult removals". Could this hide useful monotonicity structure?
- [ ] Clean up Classic RW CFTP illustration: need to produce figures using `julia` within the `qmd` document.
- [ ] Visual discussion of use of LFE and NFZ in continuous algorithmic time
  - [ ] Sequence of snapshots {==part done==}
  - [ ] add iterations of NFZ
  - [ ] add iterations of LFE
- [ ] Visual proof of monotonicity for LFE and NFZ
  - [x] LFE
  - [x] NFZ
  - [x] Overall proof
  - [x] Final verifications
  - [ ] Include different initial conditions
  - [ ] Diagrams?
  
- [ ] Visual proof of finite coalescence time using small set analysis and image in appendix.
- [ ] Is there a `domCFTP` approach? for example pure birth with barrier, birth-rate dependent on number of removals alone?
- [x] LFE: "Laziest Feasible Epidemic" rather than "Last Feasible Epidemic"?

------

- [x] Find out way to pre-process to enable {==highlight marking==} in `quarto`!
