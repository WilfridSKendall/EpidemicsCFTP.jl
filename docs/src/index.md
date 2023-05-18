```@meta
CurrentModule = EpidemicsCFTP
DocTestSetup = quote
 using EpidemicsCFTP
end
```

# Julia module `EpidemicsCFTP`
![Small julia logo](image/small-julia.png)

This is a very brief description of the following module (under development).

```@docs
EpidemicsCFTP
```

The module aims to provide perfect simulation for a ``$\text{S-I-R}$`` system obeying the Markov chain transition rates
```math
\begin{align*}
S \to S-1\,, \quad I \to I+1 \qquad & \text{ at rate } \alpha S I
\cr
I \to I-1\,, \quad R \to R+1 \qquad & \text{ at rate } \beta I
\end{align*}
```

```@contents
```

## How to install the package and produce documentation
Create source for a package (see for example <https://julialang.org/contribute/developing_package/>).

In `pkg` mode (pressing `]`):

1. Inform `pkg` that package folder exists and is under development with `dev`.
```julia
(v1.0) pkg> dev ~/.julia/dev/EpidemicsCFTP
```
2. Check that package can be seen.
```julia
(v1.0) pkg> status
```
3. Check that everything passes: this triggers performance of unit tests.
```julia
(v1.0) pkg> test EpidemicsCFTP
```

Produce this documentation as follows: in directory `EpidemicsCFTP`, run `make`, or `make-pdf`.


## Representing different types of incidents

### Various abstract incidents and associated methods
```@docs
AbstractIncident
AbstractRemoval
show(::IO, ::AbstractRemoval)
isless(::AbstractIncident, ::AbstractIncident)
```

### Two different kinds of `Removal`s
```@docs
Removal
CRemoval
```

### Two different kinds of `Infection`s
```@docs
Infection
PInfection
```

### Index
 
```@index
```
