# Initial Documentation

## Information concerning `EpidemicsCFTP`  

Here is the documentation string for the module (under development):
```@docs
EpidemicsCFTP
```

Software version information is as follows:
```@eval
import Markdown, EpidemicsCFTP
Markdown.parse("""
| _Software_             | _Version_                  | _Branch_                  | _Date of last commit_  |
|:-----------------------|:---------------------------|:--------------------------|:-----------------------|
| Running under `julia`  | `$VERSION`                 | ---                       |                        |
| Module `EpidemicsCFTP` | `$(EpidemicsCFTP.version)` | `$(EpidemicsCFTP.branch)` | $(EpidemicsCFTP.date)  |
""")
```


## Information concerning installation
General advice on developing a `julia` package is given at 
[`julialang.org/contribute/developing_package`](https://julialang.org/contribute/developing_package/).
Here is a basic summary. Working in `pkg` mode (using `]` at `julia` prompt):

1. Inform `pkg` that the package folder exists and is under development with `dev`.
(You may wish to do this within a particular `julia` environment.)
```julia
(v1.0) pkg> dev ~/.julia/dev/EpidemicsCFTP
```
2. Check that the package can be seen by `julia`.
```julia
(v1.0) pkg> status
```
3. Check that everything passes: by triggering performance of unit tests.
```julia
(v1.0) pkg> test EpidemicsCFTP
```

An alternative way to test the package is to run `make test` in the directory `EpidemicsCFTP`.
One should run `make doctest` to perform doctests.

Documentation is produced as follows: in directory `EpidemicsCFTP`, 

* run `make view` (for `gitbook` documentation)
* or `make view-pdf` (for `pdf` documentation).
