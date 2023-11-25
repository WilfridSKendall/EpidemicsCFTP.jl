# Julia notebooks for `EpidemicsCFTP`. 

## Producing primary files
Primary files are produced by `quarto`. At the of writing these files are

* `test.qmd` comprising some unit tests for `EpidemicsCFTP`;
* `introduction.qmd` introducing the basic ideas of `EpidemicsCFTP`;
* `production.qmd` generating figures for the paper;
* `experiment.qmd` containing various experimental constructions.

Run the `quarto`notebooks using (for example)
```bash
quarto render introduction.qmd --to pdf
```
or alternatively use `make` (for example)
```
make introduction.pdf
```

## Checking whether any changes of code alter figures

Illustrative figures are produced in the `image` subdirectory, such as

![](/home/wilfrid/ms/PerfectEpidemics/julia/image/introduction-18-one-iteration.png)

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
