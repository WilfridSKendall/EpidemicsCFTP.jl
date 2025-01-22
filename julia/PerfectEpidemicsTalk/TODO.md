#  TODO list for Perfect Epidemics 

#  17 January 2025

## Forthcoming

- [x] Examples: clean up code producing innovations
- [ ] Discuss with Simon Spencer
- [ ] What about compartment models:
  - [ ] Two compartments?
  - [ ] **Each individual in its own compartment?** (I fear monotonicity will fai!! but it would be useful to see how.)
    - [ ] Focus on LFE and NFZ
      - [ ] NFZ seems straightforward to design, but monotonicity may be challenging of course
      - [ ] LFE probably shouldn't be defined as trajectory! Perhaps first compute number of different paths infecting each incident? 
- [ ] Follow-up further on Paul Jenkins' remarks concerning links to "look-down" representation. I don't think there is a big thing here, but need to tie it down.
- [ ] Clean up Classic RW CFTP illustration: need to produce figures using `julia` within the `qmd` document.
- [ ] Visual discussion of developing use of LFE and NFZ in continuous algorithmic time.
- [ ] Visual proof of monotonicity for LFE and NFZ.
- [ ] Visual proof of finite coalescence time using small set analysis and image in appendix.
- [ ] Study Gareth Roberts' remarks on "occult removals". Could this hide useful monotonicity structure?
- [ ] Is there a `domCFTP` approach? for example pure birth with barrier, birth-rate dependent on number of removals alone?

