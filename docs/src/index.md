```@meta
CurrentModule = EpidemicsCFTP
DocTestSetup = quote
 using EpidemicsCFTP
end
```


# Julia module `EpidemicsCFTP` 

Here is a brief description of the following module (under development):

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

In `pkg` mode (using `]` at `julia` prompt):

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

Alternative way to test package: in directory `EpidemicsCFTP`, run `make test`.
For doctests, run `make doctest`.

Produce this documentation as follows: in directory `EpidemicsCFTP`, 
run `make view` (for `gitbook` documentation)
or `make view-pdf` (for `pdf` documentation).


## Representing different types of incidents
Everything is built on the `AbstractTimedOccurrence`.
The only requirement on ojections of this type is that they should possess
a real-valued attribute `t` corresponding to a (process) time.
```@docs
AbstractTimedOccurrence
```

### Various abstract incidents
`AbstractIncident` is a generic type for incidents taking place in time.
`AbstractRemoval` and `AbstractInfection` are generic incidents corresponding
to potential removals and potential incidents respectively.
`AbstractMarker` is a generic type for a marker to be added programmatically
(_not_ by the user) to indicate state of each time-line at end of its duration.
```@docs
AbstractIncident
AbstractRemoval
AbstractInfection
AbstractMarker
AbstractSusceptibleMarker
AbstractInfectionMarker
AbstractRemovalMarker
```


### Two different kinds of `AbstractRemoval`s
`Removal` and `CRemoval` are specific potential removal incidents: 
`CRemoval` is reserved for realized removals (which in our application
are always conditioned to happen).
```@docs
Removal
CRemoval
```

### Two different kinds of `AbstractInfection`s
`Infection` and `PInfection` are specific potential infection incidents;
`PInfection` is reserved for infections which are perpetuated from an earlier stage of the CFTP run.
```@docs
Infection
PInfection
```

### Ten different kinds of `AbstractMarker`s
`MarkerInfectionA`, `MarkerInfectionB`,
`MarkerRemovalA`, `MarkerRemovalB` are added programmatically
(_not_ by the user) to indicate state of each time-line at start of its 
infection (respectively, removal).

`InitialRemoved`,
`InitialInfected`,
`InitialSusceptible`,
`ContinuingSusceptible`,
`ContinuingInfected` and
`ContinuingRemoved` are added programmatically
(_not_ by the user) to indicate state of each time-line at start or end of 
the simulated time-line.
```@docs
InitialSusceptible
InitialInfected
InitialRemoved

MarkerInfectionA
MarkerInfectionB
MarkerRemovalA
MarkerRemovalB

ContinuingSusceptible
ContinuingInfected
ContinuingRemoved
```

## Representing different kinds of environments and states
`AbstractEnvironment` is a generic type for a collection of lists of `infections`,
`removals` and `cremovals` (conditioned removals).
```@docs
AbstractEnvironment
```

`Innovations` fills the lists of an abstract environment with simulated contents
of lists of the requisite infections or removals.
```@docs
Innovation
```

`SIR` records the state of an \(SIR\) epidemic at a stipulated time.
```@docs
SIR
```

## Associated methods

### Display methods
These overload `show` (to provide compact displays)
```@docs
show(::IO, ::AbstractRemoval)
show(::IO, ::AbstractInfection)
show(::IO, ::AbstractMarker)
show(::IO, ::Innovation)
show(::IO, ::SIR)
```
### Comparison method
A partial order is provided by `isearlier`, based on time `t` of occurrence of the relevant 
instances of
`AbstractTimedOccurrence`s.
```@docs
isearlier(::AbstractTimedOccurrence, ::AbstractTimedOccurrence)
```

### Conversion methods
A couple of methods concern conversion of one incident into another, possibly of a different type.
```@docs
resample
perpetuate
```
### Other methods
The method
`evolution_recurse!` 
**(NOT YET FULLY TESTED)**
extends a pair of lists of

1. a trajectory of states, and
2. a history of events

using a chronology of incidents.
```@docs
evolution_recurse!
```

**NOTE** that this method alters the list structures which are its arguments.
It is therefore deprecated in favour of the method
`evolution` given below.
```@docs
evolution
```

Various private methods relating to updating a trajectory:
```@docs
infect
is_infectable
remove
is_removeable
is_same_config
update
```

# Index 
```@index
```
