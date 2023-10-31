
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
The first set concerns generation of a random [`Innovation`](@ref)
(`generate_innovation`)
and production of an [`Evolution`](@ref) based on an initial [`SIR`](@ref) and 
an [`Innovation`](@ref)
([`evolution`](@ref) for trajectory and history, [`EpidemicsCFTP.periods`](@ref) for start and end times for infectious periods, [`EpidemicsCFTP.inactive_removals`](@ref) to process a list of the removals
from an epidemic which are inactive).
```@docs
generate_innovation
evolution
EpidemicsCFTP.periods
EpidemicsCFTP.inactive_removals
```

The second set is employed in the course of applying `evolution` to generate trajectory and history
in the course of initializing an [`Innovation`]](@ref).
```@docs
EpidemicsCFTP.infect
EpidemicsCFTP.is_infectable
EpidemicsCFTP.remove
EpidemicsCFTP.is_removeable
EpidemicsCFTP.is_same_config
EpidemicsCFTP.update
```
