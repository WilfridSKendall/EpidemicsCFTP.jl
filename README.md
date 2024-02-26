# EpidemicsCFTP.jl

This is a `julia` package, currently under development, which is intended to implement Coupling from the Past (CFTP) for $\operatorname{S-I-R}$ epidemics with observed removals.

Requirements
------------
The package is being implemented using `Julia` 1.9.2 (as of `26-02-2024`)

> [!NOTE]
>
> See `REQUIRE` for required `Julia` packages.

Preliminary requirements:
```bash
please apt install python3-pygments
pip install mkdocs
pip install python-markdown-math
```
(Note: unsure whether we need `python3-pygments` or `python2-pygments`!

Currently installed as developer package.

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

## TODO list

- [ ] `26-02-2024` Introduce type `CInnovation`.
  
  - [x] `26-02-2024` Add bare type.
  
  - [ ] `26-02-2024`  Arrange for this automatically to create `finis` field from `cremoval` list using `create_finis` (see below) and then render `KilledInfection`s in `infections` field and `KilledRemoval`s in `removals` field as appropriate.
  - [ ] `26-02-2024` To this end, break up `interval` function into `create_finis` and `create_start` functions.
  - [ ] `26-02-2024` Then add  `CEvolution(::AbstractEvolution,::CInnovation)` , and make  `CEvolution(::AbstractEvolution,::Innovation)`  factor through the new function.  
  - [ ] `26-02-2024` Add a specific `CEvolution(::CEvolution,::CInnovation)` .
  
- [ ] `26-02-2024` Refactor `CEvolution(::AbstractEvolution,::Innovation)` to compute `NFZ` in a separate function, using `compute_NFZ(::CEvolution,::Innovation)`.

- [ ] `26-02-2024` Refactor `CEvolution(::AbstractEvolution,::Innovation)` to be efficient about use of `resulting_cremovals(::AbstractEvolution,::Innovation)` function.

- [ ] `26-02-2024` Check for functions which can be deprecated (use `@warn`) then removed.
