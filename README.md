# EpidemicsCFTP.jl

This is a `julia` package, currently under development, 
which is intended to implement Coupling from the Past (CFTP) 
for `SIR` epidemics with observed removals.

Requirements
------------
The package is implemented using `Julia` 1.13.3 (as of `23-11-2026`)

Preliminary requirements:
```bash
please apt install python3-pygments
pip install mkdocs
pip install python-markdown-math
```
(Note: unsure whether we need `python3-pygments` or `python2-pygments`!)

Currently installed as developer package.

## Caveats

This is one of the first `julia` packages I have written.

1. Its documentation system is tested only for PDF output.

2. Documentation incidentally uses the `Compose` package for graphics (*via* the associated `EpidemicsUtilities.jl` package).
   I hope eventually to re-write `EpidemicsUtilities.jl` based on a graphics
   package which is more actively maintained.

Abbreviations
----------

These are introduced in the submodule `EpidemicsCFTP.abbreviations` and are given by:

```julia
AI  = AbstractIncident;
AIF = AbstractInfection;  I = Infection; P = PInfection;
 NF = NoFlyInfection;    XI = ExpungedInfection;
AIR = AbstractRemoval;    R = Removal;   C = CRemoval;
 KI = KilledInfection;   KR = KilledRemoval;
IM  = InfectionMarker;   RM = RemovalMarker;
```

Typically these are imported individually according to need.

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

