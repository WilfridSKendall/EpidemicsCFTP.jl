# Julia notebooks for `EpidemicsCFTP`. 

## Producing primary files
Primary files are produced by `quarto`. At the time of writing these files are

* `CFTP.qmd` running a simple example of `CFTP`;

* `test.qmd` comprising some unit tests for `EpidemicsCFTP`;

* `LFEandNFZ.qmd` developing some tests for correctness of `LFE` and `NFZ` fields;

* `check.qmd` running some statistical simulation tests;

* `introduction.qmd` introducing the basic ideas of `EpidemicsCFTP`;

* `production.qmd` generating figures for the paper.

* `Notes-on-sampling.qmd` making some observations on how to estimate $\operatorname{S-I-R}$ parameters;

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

- [ ] `[24/02/2024]`Update `*.qmd` to use  `CInnovation` type.

  > [!NOTE]
  >
  > Depends on entry in TODO list for `EpidemicsCFTP` module.

- [ ] `[24/02/2024]`Extend `CFTP.qmd` to cover a more extensive example using more `CRemoval`s.

- [ ] `[24/02/2024]`Move unit tests from `test.qmd` to `EpidemicsCFTP/test`. 

- [ ] `[24/02/2024]`Extend `production.qmd` to use more recent code and to cover more figures.

## Checking whether any changes of code alter figures

Illustrative figures are produced in the `image` subdirectory, such as

![](/home/wilfrid/ms/PerfectEpidemics/julia/image/CFTP-01-minstep4.png)

To check that  pictures have not changed from reference versions (`image/VERIFY_*.png` use
```bash
make verify
```
(the reference `VERIFY_*.png` is compared against the image without the `VERIFY_` prefix;
a visual summary of the difference is presented if they do differ).

## Modules

These are

1. `EpidemicsCFTP` containing types and functions for simulations;
2. `EpidemicsUtilities` containing code for producing `Gadfly` graphics. 

## Old code, modules and figures
Inspect `ARCHIVE`.

## Manual for `julia 1.9`

See `Julia-2023.pdf`.
