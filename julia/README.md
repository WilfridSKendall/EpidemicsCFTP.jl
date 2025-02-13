# Julia notebooks for `EpidemicsCFTP`. 

![](/home/wilfrid/ms/PerfectEpidemics/julia/animation/VERIFY_demo-e.png)

## Producing primary files
Primary files are produced by `quarto`. At the time of writing these files are

* [`CFTP-demo.qmd`](file://CFTP-demo.qmd) running `CFTP` on real data and constructing [an animation as a `GIF`](file://animation-demo.gif).

* [`CFTP.qmd`](file://CFTP.qmd) running a simple example of `CFTP`;

* [`figures.qmd`](file://figures.qmd) generates figures for paper per SBC suggestions;

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

See [`Julia-2024.pdf`](Reading/Julia-2024.pdf).

------

