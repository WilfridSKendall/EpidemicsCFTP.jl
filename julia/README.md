# Julia notebooks for `EpidemicsCFTP`. 

![](/home/wilfrid/ms/PerfectEpidemics/julia/animation/VERIFY_demo-e.png)

## Producing primary files
Primary files are produced by `quarto`. At the time of writing these files are

* [`CFTP-demo.qmd`](file://CFTP-demo.qmd) running `CFTP` on real data and constructing [an animation as a `GIF`](file://animation-demo.gif).

* [`CFTP.qmd`](file://CFTP.qmd) running a simple example of `CFTP`;

* figures.qmd generates figures for paper per SBC suggestions;

* [`test.qmd`](file://test.qmd) comprising some unit tests for `EpidemicsCFTP`;

* [`LFEandNFZ.qmd`](file://LFEandNFZ.qmd) developing some tests for correctness of `LFE` and `NFZ` fields;

* [`check.qmd`](file://check.qmd) running some statistical simulation tests;

* [`introduction.qmd`](file://introduction.qmd) introducing the basic ideas of `EpidemicsCFTP`;

* [`production.qmd`](file://production.qmd) generating figures for the paper.

* [`Notes-on-sampling.qmd`](file://Notes-on-sampling.qmd) making some observations on how to estimate $\operatorname{S-I-R}$ parameters;

  > [!NOTE]
  >
  > No `julia` in the document `Notes-on-sampling.qmd`!

Run the `quarto`notebooks using (for example)
```bash
quarto render introduction.qmd --to pdf
```
or alternatively use `make`: for example
```
make introduction.pdf
```

Make an `mp4` movie using

```
make movie
```

and make a `gif` animation using

```
make animation
```

## Checking whether any changes of code alter figures

Illustrative figures are produced in the `image` subdirectory, such as

![](/home/wilfrid/ms/PerfectEpidemics/julia/image/CFTP-01-minstep4.png)

To check that  pictures have not changed from reference versions (`image/VERIFY_*.png`, `animation/VERIFY_*.png`), use one of
```bash
make verify
make verify-image
make verify-animation
```
(the reference `VERIFY_*.png` is compared against the image without the `VERIFY_` prefix; a visual summary of the difference is presented if there is a difference).

## Modules

These are

1. [`EpidemicsCFTP`](file://EpidemicsCFTP/) containing types and functions for simulations;
2. [`EpidemicsUtilities`](file://EpidemicsUtilities/) containing code for producing `Gadfly` graphics. 

## Old code, modules and figures
Stored in [`ARCHIVE`](file:..ARCHIVE/).

## Manual for `julia 1.11`

See [`Julia-2024.pdf`](file:///home/wilfrid/ms/PerfectEpidemics/juliaReading/Julia-2024start Read	.pdf).

------

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

