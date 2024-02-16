# EpidemicsCFTP

EpidemicsCFTP.jl
================
This is a `julia` package, currently under development, which is intended to implement Coupling from the Past (CFTP) for S-I-R epidemics with observed removals.

Requirements
------------
The package is being implemented using `Julia` 1.9.2 (as of 30 October 2023).

<!-- See `REQUIRE` for required `Julia` packages. -->

Preliminary requirements:
```bash
please apt install python3-pygments
pip install mkdocs
pip install python-markdown-math
```
(Note: unsure whether we need `python3-pygments` or `python2-pygments`!

Currently installed as developer package.

Unit Tests
----------
Test in `julia` within directory `EpidemicsCFTP` environment by
```julia
Pkg.activate(".")
Pkg.test("EpidemicsCFTP")
```
or simply run the following in `bash`:
```bash
make test
```

DocTests
--------
Working in `bash`,
```bash
make doctest
```

Documentation
-------------
For `gitbook` format, working in `bash`,
```bash
make html-format
```

PDF documentation
-----------------
For `pdf` format, working in `bash`,
```bash
make pdf-format
```

