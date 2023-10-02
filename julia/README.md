# Julia notebooks for `EpidemicsCFTP`. 

## Producing primary files
Primary files are produced by `quarto`. At the of writing these files are

* `introduction.qmd` introducing the basic ideas of `EpidemicsCFTP`;
* `production.qmd` generating figures for the paper;
* `experiment.qmd` containing various experimental cnstructions.

Run notebooks using (for example)
```bash
quarto render introduction.qmd --to pdf
```
or (for example)
```
make experiment.pdf
```

## Checking whether any changes of code alter figures

Nice figures are produced in `image` subdirectory such as

![](/home/wilfrid/ms/PerfectEpidemics/julia/image/introduction-processed-cremovals.png)

To check that the key pictures have not changed from reference versions (`image/VERIFY_*.png` use
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
