# Julia notebooks. 


Run the notebooks using (for example)
```bash
quarto render figures.qmd --to pdf
```

Nice figures are produced in `image` subdirectory such as

![](/home/wilfrid/ms/PerfectEpidemics/julia/image/processed-cremovals.png)

Check key pictures have not changed from before using

```bash
make verify
```

(compare `VERIFY_*.png` against the image without the `VERIFY_` prefix!).
