## TODO list

- [ ] `22/03/2024` Things remaining to be done for `CFTP-demo.qmd`:

  - [ ] Clean up the code!
    - [ ] Move some of the specialized choices and functions of section 2 into the [`EpidemicsUtilities`](file://EpidemicsUtilities/) module,
    - [ ] How to speed up by doing more in memory?!
    - [ ] More unit tests are needed!
      - [ ] `28/04/2024` Generate graphics with `CFTP.qmd` to help validate automatic unit tests.
      - [ ] `24/02/2024` Move unit tests from `test.qmd` to `EpidemicsCFTP/test`. 
  - [x] Compute the prior distribution of infectives at time `0` given α and β, if the first `CRemoval` occurs at time `0`. 
    - [ ] Produce simple RWM variant for proposal of new initial state. Check requirements if monotonicity is to be maintained.
  - [ ] Generate code for automatic extension of CFTP.
- [ ] Statistical application:
  - [ ] Adapt to search out _maximum a posteriori_ estimates for the parameters.
  - [ ] Map out posterior distribution up to a normalizing factor.
  - [ ] likelihood test for presumed $\alpha$ and $\beta$?
  - [ ] steepest ascent search for m.a.p. estimator?
  - [ ] estimate posterior density for $\alpha$ and $\beta$​? 
- [ ] **Clean up perfect SIR simulations:** 
  - [x] I want an `MP4` for small-pox dataset requiring just 128 steps of algorithmic time;
  - [x] Ditto for `GIF`
  - [x] I want a systematic colour scheme;
  - [ ] How about a closer focus on what is happening in top-right corner for maximal process? (early time, high number of actual infectives).
- [x] `24/02/2024` Extend `production.qmd` to use more recent code and to cover more figures. (Now done in `figures.qmd`.)

 
