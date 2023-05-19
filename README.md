# EpidemicsCFTP

[![Build Status](https://github.com/WilfridSKendall/EpidemicsCFTP.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/WilfridSKendall/EpidemicsCFTP.jl/actions/workflows/CI.yml?query=branch%3Amain)

EpidemicsCFTP.jl
================
This is a `julia` package, currently under development,
which is intended to implement Coupling from the Past (CFTP)
for S-I-R epidemics with observed removals.

Requirements
------------
The package is being implemented using `Julia` 1.9.0 (as of 17 May 2023).

<!-- See `REQUIRE` for required `Julia` packages. -->

Need
```bash
please apt install python3-pygments
pip install mkdocs
pip install python-markdown-math
```
(Note: unsure whether we need `python3-pygments` or `python2-pygments`!

Installed as developer package. Test within directory `EpidemicsCFTP` environment by
```julia
Pkg.activate(".")
Pkg.test("EpidemicsCFTP")
```



Tests
-----
Working in `bash`,
```{bash}
cd ~/.julia/dev/EpidemicsCFTP # this directory
make test
make doctest
```

Documentation
-------------
For `gitbook` format, working in `bash`,
```{bash}
cd ~/.julia/dev/EpidemicsCFTP # this directory
make view
```


-------------
For `pdf` format, working in `bash`,
```{bash}
cd ~/.julia/dev/EpidemicsCFTP # this directory
make view-pdf
```

