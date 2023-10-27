
# Abstract timed occurrences
Most entities of `EpidemicsCFPT` are based on the generic type `AbstractTimedOccurrence`.
The only requirement on objects of this type is that they should possess
a real-valued attribute `t` corresponding to a (process) time.
```@docs
AbstractTimedOccurrence
```
This has sub-types `AbstractIncident` 
(whose sub-types correspond to various kinds of _possible_ infections and removals)
and `SIR` 
(representing the state of the ``\operatorname{S-I-R}`` 
incident at a particular moment of time). 

[`AbstractTimedOccurrence`](@ref)

## State of an epidemic
`SIR` is a type for recording the state of an $SIR$ epidemic at a stipulated time, based on [`AbstractTimedOccurrence`](@ref).
```@docs
SIR
```

## Abstract incidents
`AbstractIncident` is a generic type for incidents taking place in time, based on [`AbstractTimedOccurrence`](@ref).
```@docs
AbstractIncident
```

It has sub-types
[`AbstractRemoval`](@ref) and [`AbstractInfection`](@ref), generic incidents corresponding
to potential removals and potential incidents respectively.

### `AbstractRemoval`
`AbstractRemoval` is a generic sub-type of [`AbstractIncident`](@ref)
Further generic sub-types are
[`OperativeRemoval`](@ref) and [`NonOperativeRemoval`](@ref), used to distinguish between
potential removal incidents
that will, respectively will not, be allowed to form part of 
an epidemic trajectory.
```@docs
AbstractRemoval
OperativeRemoval
NonOperativeRemoval
```
Concrete sub-types are tabulated as follows:

| Type of `AbstractRemoval` | Sub-type of            | Explanation                                         |
|:--------------------------|:-----------------------|:----------------------------------------------------|
| `Removal`                 | `OperativeRemoval`     | Remove an infection if `target` infected            | 
| `CRemoval`                | `OperativeRemoval`     | As above but **conditioned** to be removed          | 
|                           |                        |                                                     |
| `KilledRemoval`           | `NonOperativeRemoval`  | Never to be removed (expect error if this happens!) | 

#### Two different kinds of [`OperativeRemoval`](@ref)s
`Removal` and `CRemoval` are specific potential removal incidents: 
`CRemoval` is reserved for realized removals (which in our application
are always conditioned to happen).
```@docs
Removal
CRemoval
```
#### One kind of [`NonOperativeRemoval`](@ref)
`KilledRemoval` is a further kind of removal which will _never_ be realized.
```@docs
KilledRemoval
```

### `AbstractInfection`
`AbstractInfection` incidents are sub-typed as
[`OperativeInfection`](@ref) and [`NonOperativeInfection`](@ref), used to distinguish between
potential infection incidents
that will, respectively will not, be allowed to form part of 
an epidemic trajectory.
```@docs
AbstractInfection
OperativeInfection
NonOperativeInfection
```
Concrete sub-types are tabulated as follows:

| Type of `AbstractInfection` | Sub-type of             | Explanation                                              |
|:----------------------------|---------|:-------------------------------------------------------------------------|
| `Infection`                 | `OperativeInfection`    | Supplied by new `Innovation`                             | 
| `PInfection`                | `OperativeInfection`    | Held over from previous `Innovation`                     | 
| `NoFlyInfection`            | `OperativeInfection`    | `infectee` leads to "no-fly" zone                        | 
|                             |                         |----------------------------------------------------------|
| `KilledInfection`           | `NonOperativeInfection` | `target` removed                                         | 
| `CancelledInfection`        | `NonOperativeInfection` | `target` infected, `infectee` leads to "no-fly" zone     | 

#### Three different kinds of `OperativeInfection`s
`Infection` and `PInfection` are specific potential infection incidents;
`PInfection` is reserved for infections which are perpetuated from an earlier stage of the CFTP run.
`NoFlyInfection` is reserved for infections which, if activated, lead in due to activation
of an unconditioned removal (and thus to an error if the evolution is conditioned on observing
all activated removals as `CRemoval`s).

```@docs
Infection
PInfection
NoFlyInfection
```

#### Two different kinds of `NonOperativeInfection`s
`KilledInfection`,
`CancelledInfection` are specific non-operative infection incidents as tabulated.
They are _never_ realized!

```@docs
KilledInfection
CancelledInfection
```

# Representing different kinds of environments
`AbstractEnvironment` is a generic type for a collection of lists of `infections`,
`removals` and `cremovals` (conditioned removals).
```@docs
AbstractEnvironment
AbstractEvolution
```

## `Innovation`
`Innovation` fills the lists of an abstract environment with simulated contents
of lists of the requisite infections or removals. 
```@docs
Innovation
```

## Two kinds of `Evolution`
`Evolution` carries out the simulation of an epidemic from a given initial `SIR` value,
based on an `Innovation`. 
`CEvolution` does the same, but returns an error if it violates conditioning 
in the way it treats`AbstractRemoval`s.
(This distinctive behaviour is implemented in the [`evolution`](@ref) function
when the `conditioned` keyword is set to `true`.)
```@docs
Innovation
Evolution
CEvolution
```


