```@meta
CurrentModule = EpidemicsCFTP
DocTestSetup = quote
 using EpidemicsCFTP
end
```

# Introduction

## Abstract
The package 
[`EpidemicsCFTP`](https://github.com/WilfridSKendall/EpidemicsCFTP.jl)
provides 
[`julia`](https://julialang.org/) 
object types and methods
to perform perfect simulation (_CFTP_) of epidemics conditioned on observed (_active_) removals.
The aim is to provide 
Coupling from the Past
[ProppWilson-1996a](@cite)
for a `S-I-R` epidemic
conditioned on all (observed) removal times and 
making transitions according to the following rates:
```math
\begin{aligned}
S \to S-1\,, \quad I \to I+1 \qquad & \text{ at rate } \alpha \; S I \,,
\cr
I \to I-1\,, \quad R \to R+1 \qquad & \text{ at rate } \beta \; I    \,.
\end{aligned}
```

The simulation mechanism uses "algorithmic time" to vary an event-based simulation such that  
1. detailed balance holds with respect to algorithmic time, 
2. respects the conditioning on active removals,
3. possesses sufficient monotonicity to permit construction of a classical CFTP algorithm.

![A snap-shot of a simulation produced by `EpidemicsCFTP`.](image/introduction-18-one-iteration.pdf)

    
#### Reference

```@bibliography
```


## Information 


#### General advice on installation
General advice on developing a `julia` package is given at 
[`julialang.org/contribute/developing_package`](https://julialang.org/contribute/developing_package/).
Here is a basic summary. Working in `pkg` mode (using `]` at `julia` prompt):  
* Inform `pkg` that the package folder exists and is under development with `dev`. (You may wish to do this within a particular `julia` environment.)  
```julia
(v1.0) pkg> dev ~/.julia/dev/EpidemicsCFTP
```
* Check that the package can be seen by `julia`.  
```julia
(v1.0) pkg> status
```
* Check that everything passes: by triggering performance of unit tests.  
```julia
(v1.0) pkg> test EpidemicsCFTP
```
(An alternative way to test the package is to run `make test` in the directory `EpidemicsCFTP`.
Run `make doctest` to perform doctests.)
* Commit and push to `github` with `make commit`.
* Documentation is produced as follows: in directory `EpidemicsCFTP`,  
    - run `make documentation
    - run `make html-documentation` (for `gitbook` documentation)
    - or `make pdf-documentation` (for `pdf` documentation).

#### Specifics concerning `EpidemicsCFTP`  

```@eval
import Markdown, EpidemicsCFTP
Markdown.parse("""
| _Software_             | _Version_                  | _Branch_                  | _Date of last commit_  |
|:-----------------------|:---------------------------|:--------------------------|:-----------------------|
| Running under `julia`  | `$VERSION`                 | --                        |                        |
| Module `EpidemicsCFTP` | `$(EpidemicsCFTP.version)` | `$(EpidemicsCFTP.branch)` | $(EpidemicsCFTP.date)  |
""")
```

Documentation string for the module (under development):
```@docs
EpidemicsCFTP
```

