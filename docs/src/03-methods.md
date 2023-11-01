
# Associated methods

## Comparison method
A partial order is provided by [`isearlier`](@ref), based on time `t` of occurrence of 
the two arguments, which should be 
instances of
[`AbstractTimedOccurrence`](@ref)s.
```@docs
isearlier(::AbstractTimedOccurrence, ::AbstractTimedOccurrence)
```

## Conversion methods
A method concerning conversion of one incident into another.
```@docs
alter
```

## Methods relating to epidemic dynamics
Various methods relating to updating a trajectory (some of these are private to `EpidemicsCFTP`!).
The first set of methods concerns the generation of a random [`Innovation`](@ref)
([`generate_innovation`](@ref))
and production of an [`Evolution`](@ref) based on an initial [`SIR`](@ref) and 
an [`Innovation`](@ref)
([`evolution`](@ref) for trajectory and history, 
also other helper functions:

| Method                                    | Summary                                                                |
|:------------------------------------------|:-----------------------------------------------------------------------|
| [`generate_innovation`](@ref)             | Generates random [`Innovation`](@ref)                                  |
| [`evolution`](@ref)                       | Generates trajectory and history for an [`Evolution`](@ref)            |
|                                           |                                                                        |
| [`EpidemicsCFTP.periods`](@ref)           | Computes start and end times for infectious periods                    |
| [`EpidemicsCFTP.inactive_removals`](@ref) | Processes list of inactive removals from an epidemic                   |
| [`EpidemicsCFTP.accept_reject`](@ref)     | Performs accept/reject procedure on a proposed [`CRemoval`](@ref)      |
```@docs
generate_innovation
evolution
EpidemicsCFTP.periods
EpidemicsCFTP.inactive_removals
EpidemicsCFTP.accept_reject
```

The second set of methods is a set of utility methods which are
employed in the course of applying `evolution` to generate trajectory and history
in the course of initializing an [`Innovation`]](@ref):

| Method                                 | Summary                                                            |
|:---------------------------------------|:-------------------------------------------------------------------|
| [`EpidemicsCFTP.infect`](@ref)         | Implements an [`Infection`](@ref)                                  |
| [`EpidemicsCFTP.is_infectable`](@ref)  | Checks whether an [`Infection`](@ref) can be implemented           |
| [`EpidemicsCFTP.remove`](@ref)         | Implements a [`Removal`](@ref)                                     |
| [`EpidemicsCFTP.is_removeable`](@ref)  | Checks whether a [`Removal`](@ref) can be implemented              |
| [`EpidemicsCFTP.is_same_config`](@ref) | Tests whether two [`SIR`](@ref) agree up to but not including time |
| [`EpidemicsCFTP.update`](@ref)         | Updates an [`SIR`](@ref), given an [`AbstractIncident`](@ref)`     |
```@docs
EpidemicsCFTP.infect
EpidemicsCFTP.is_infectable
EpidemicsCFTP.remove
EpidemicsCFTP.is_removeable
EpidemicsCFTP.is_same_config
EpidemicsCFTP.update
```
