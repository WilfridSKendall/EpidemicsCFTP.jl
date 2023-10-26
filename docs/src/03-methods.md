
# Associated methods

## Comparison method
A partial order is provided by `isearlier`, based on time `t` of occurrence of 
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
Various methods relating to updating a trajectory (some private):
```@docs
evolution
generate_innovation
EpidemicsCFTP.infect
EpidemicsCFTP.is_infectable
EpidemicsCFTP.remove
EpidemicsCFTP.is_removeable
EpidemicsCFTP.is_same_config
EpidemicsCFTP.update
```
