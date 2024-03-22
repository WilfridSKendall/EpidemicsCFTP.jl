# Julia notebooks for `EpidemicsCFTP`. 

## Producing primary files
Primary files are produced by `quarto`. At the time of writing these files are

* [`CFTP-demo.qmd`](file://CFTP-demo.qmd) running `CFTP` on real data and constructing [an animation as a `GIF`](file://animation-demo.gif).

* [`CFTP.qmd`](file://CFTP.qmd) running a simple example of `CFTP`;

* [`test.qmd`](file://test.qmd) comprising some unit tests for `EpidemicsCFTP`;

* [`LFEandNFZ.qmd`](file://LFEandNFZ.qmd) developing some tests for correctness of `LFE` and `NFZ` fields;

* [`check.qmd`](file://check.qmd) running some statistical simulation tests;

* [`introduction.qmd`](file://introduction.qmd) introducing the basic ideas of `EpidemicsCFTP`;

* [`production.qmd`](file://production.qmd) generating figures for the paper.

* [`Notes-on-sampling.qmd`](file://Notes-on-sampling.qmd) making some observations on how to estimate $\operatorname{S-I-R}$ parameters (no `julia` code in this document);

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

## TODO list

- [x] `24/02/2024`Update `*.qmd` to use  `CInnovation` type.

  > [!NOTE]
  >
  > Depends on entry in [TODO list for `EpidemicsCFTP`](EpidemicsCFTP/README.md) module.

- [x] `24/02/2024` Extend `CFTP.qmd` to cover a more extensive example using more `CRemoval`s.

- [x] `13/03/24` Extend `CFTP.qmd` to use `AbstractInnovation`s which forbid `Infection`s (and `Removal`s) affecting time lines above a given threshold (most typically, the highest threshold experiencing a `CRemoval`). (Alter `EpidemicsCFTP` module.)

- [x] `13/03/24` Extend `CFTP.qmd` to vary  `AbstractInnovation`s to allow for change in initial infectives, and to do _CFTP_ in this case. (Alter [`EpidemicsCFTP`](EpidemicsCFTP) module?) **BETTER?** introduce / remove initial `Infection`s at time zero?

- [ ] `22/03/2024` Things remaining to be done for `CFTP-demo.qmd`:

  - [ ] Clean up the code!
    - [x] Change `threshold` to `size`.
    - [x] Check whether update function should take a `deepcopy` (really an issue for  the [`EpidemicsUtilities`](file://EpidemicsUtilities/) module). (RESOLVED by ensuring `deepcopy` taken for constructors of `Evolution` and `CEvolution`.)
    - [x] Move initial state update function to  the [`EpidemicsUtilities`](file://EpidemicsUtilities/) module,
      - [x]  and add a "no action" option if `size` specified and would be exceeded.
    - [ ] Move some of the specialized choices and functions of section 2 into the [`EpidemicsUtilities`](file://EpidemicsUtilities/) module,
    - [ ] How to speed up by doing more in memory?!
    - [ ] More unit tests are needed!
      - [ ] `28/04/2024` Generate graphics with `CFTP.qmd` to help validate automatic unit tests.
      - [ ] `24/02/2024` Move unit tests from `test.qmd` to `EpidemicsCFTP/test`. 
  - [x] Compute the prior distribution of infectives at time `0` given α and β, if the first `CRemoval` occurs at time `0`. 
    - [x] Alter code to account for this using `CategoricalDistribution`.
    - [ ] Produce simple RWM variant for proposal of new initial state. Check requirements if monotonicity is to be maintained.
  - [ ] Generate code for automatic extension of CFTP.

- [x] `13/03/24` Extend `CFTP.qmd` to generate a `GIF`. For this, use `gadfly_animate.jl`. (Alter [`EpidemicsUtilities`](file://EpidemicsUtilities/) module?)

- [x] Improve animation.
  - [x] Modify code so times are displayed as negative running up to time 0.
  - [x] Highlight coalescence in animation.
  - [x] Pause at end of each CFTP cycle in animation.
  - [x] Previous cycles would be better plotted as greyed out.
  - [x] Coalesced trajectory as opaque black.
  
- [ ] Statistical application:
  - [ ] Adapt to search out _maximum a posteriori_ estimates for the parameters.
  - [ ] Map out posterior distribution up to a normalizing factor.
  
- [ ] `24/02/2024` Extend `production.qmd` to use more recent code and to cover more figures.

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

## Manual for `julia 1.9`

See [`Julia-2023.pdf`](file:///home/wilfrid/ms/PerfectEpidemics/juliaReading/Julia-2023.pdf).
