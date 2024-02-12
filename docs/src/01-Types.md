# Types
## Abstract timed occurrences
Most entities of `EpidemicsCFTP` are based on the generic type [`AbstractTimedOccurrence`](@ref).
The only requirement on objects of this type is that they should possess
a real-valued attribute `t` corresponding to a (process) time.
```@docs
AbstractTimedOccurrence
```
This has sub-types `AbstractIncident` 
(whose sub-types correspond to various kinds of _possible_ infections and removals)
and `SIR` 
(representing the state of the `S-I-R` 
incident at a particular moment of time). 

### The state of an epidemic
`SIR` is a type for recording the state of a `S-I-R` epidemic at a stipulated time, based on [`AbstractTimedOccurrence`](@ref).
```@docs
SIR
```

### Abstract incidents
`AbstractIncident` is a generic type for incidents taking place in time, based on [`AbstractTimedOccurrence`](@ref).
```@docs
AbstractIncident
```

It has sub-types
[`AbstractRemoval`](@ref) and [`AbstractInfection`](@ref), generic incidents corresponding
to potential removals and potential incidents respectively. The illustration
provides a visual key to the various concrete sub-types of 
[`AbstractRemoval`](@ref) and [`AbstractInfection`](@ref):

![Visual key to various sub-types of `AbstractIncident`.](image/introduction-01-key.png)

#### `AbstractRemoval`
`AbstractRemoval` is a generic sub-type of [`AbstractIncident`](@ref)
Further generic sub-types are
[`OperativeRemoval`](@ref) and [`NonOperativeRemoval`](@ref), used to distinguish between
potential removal incidents
that will, respectively will not, be allowed to form part of 
an epidemic trajectory.

Concrete sub-types are tabulated as follows:

| _Type of `AbstractRemoval`_ | _Sub-type of ..._             | _Explanation_                              |
|:----------------------------|:------------------------------|:-------------------------------------------|
| [`Removal`](@ref)           | [`OperativeRemoval`](@ref)    | Remove an infection if `target` infected   | 
| [`CRemoval`](@ref)          | [`OperativeRemoval`](@ref)    | As above but **conditioned** to be removed | 
|                             |                               |                                            |
| [`KilledRemoval`](@ref)     | [`NonOperativeRemoval`](@ref) | Raises error if activated                  |
|                             |                               |                                            |
| [`RemovalMarker`](@ref)     | [`NonOperativeRemoval`](@ref) | Signals end of epidemic                    |

```@docs
AbstractRemoval
OperativeRemoval
NonOperativeRemoval
```

#### Two different kinds of [`OperativeRemoval`](@ref)s
`Removal` and `CRemoval` are specific potential removal incidents: 
`CRemoval` is reserved for realized removals (which in our application
are always conditioned to happen).
```@docs
Removal
CRemoval
```
#### Two kinds of [`NonOperativeRemoval`](@ref)
`KilledRemoval` is a further kind of removal which will _never_ be realized.
`RemovalMarker` occurs at the end of the epidemic for a time line which is never removed.
It also is never realized.
```@docs
KilledRemoval
RemovalMarker
```

### `AbstractInfection`
`AbstractInfection` incidents are sub-typed as
[`OperativeInfection`](@ref) and [`NonOperativeInfection`](@ref), used to distinguish between
potential infection incidents
that will, respectively will not, be allowed to form part of 
an epidemic trajectory.

Concrete sub-types are tabulated as follows:

| _Type of `AbstractInfection`_ | _Sub-type of ..._             | _Explanation_                               |
|:------------------------------|:------------------------------|:--------------------------------------------|
| [`Infection`](@ref)           |[`OperativeInfection`](@ref)   | Supplied by new [`Innovation`](@ref)        |
| [`PInfection`](@ref)          |[`OperativeInfection`](@ref)   | Held over from previous [`Innovation`](@ref)|
| [`NoFlyInfection`](@ref)      |[`OperativeInfection`](@ref)   | `infectee` leads to "no-fly" zone           |
|                               |                               |                                             |
| [`KilledInfection`](@ref)     |[`NonOperativeInfection`](@ref)| `target` is in removed region               |
| [`ExpungedInfection`](@ref)   |[`NonOperativeInfection`](@ref)| Infection would infect "no-fly" zone        |
|                               |                               |                                             |
| [`InfectionMarker`](@ref)     |[`NonOperativeInfection`](@ref)| Signals start of epidemic                   |

```@docs
AbstractInfection
OperativeInfection
NonOperativeInfection
```

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

#### Three different kinds of `NonOperativeInfection`s
`KilledInfection`,
`ExpungedInfection` are specific non-operative infection incidents as tabulated.
They are _never_ realized!
`InfectionMarker` occurs at the start of the epidemic for a time line which is initially infected.
It also is never realized.

```@docs
KilledInfection
ExpungedInfection
InfectionMarker
```

### Abbreviations for `AbstractIncident`s
It is often helpful to import or use the submodule `.abbreviations` in `EpidemicsCFTP`.
```@docs
EpidemicsCFTP.abbreviations
```


## Representing different kinds of environments
`AbstractEnvironment` is a generic type for a collection of lists of `infections`,
`removals` and `cremovals` (conditioned removals).

Instances should always possess fields as given in the table. 

| _Field name_ | _Type_                      |              | _Further remarks_                 |
|:-------------|:----------------------------|:-------------|:----------------------------------|
| `infections` | `Vector{AbstractInfection}` |              | ordered list                      |
| `removals`   | `Vector{AbstractRemoval}`   |              | ordered list                      |
| `cremovals`  | `Vector{CRemoval}`          |              | ordered list if nonempty          |
| `chronology` | `Vector{AbstractIncident}`  | **computed** | ordered union of previous 3 lists |

```@docs
AbstractEnvironment
AbstractEvolution
```

### `Innovation` as an `AbstractEnvironment`
`Innovation` fills the lists of an abstract environment with (typically simulated) contents
of lists of the requisite infections or removals. 
```@docs
Innovation
```

### Two kinds of `AbstractEvolution`
`Evolution` carries out the simulation of an epidemic from a given initial `SIR` value,
based on an `Innovation`. 
`CEvolution` does the same, but returns an error if it violates conditioning 
in the way it treats`AbstractRemoval`s.
(This distinctive behaviour is implemented in the [`evolution`](@ref) function
when keyword `conditioned` keyword is `true`.)


Instances should always possess fields as given in the table.

| _Field name_  | _Type_                       |              | _Specific to_     | _Further remarks_ |
|:--------------|:-----------------------------|:-------------|:------------------|:------------------|
| `initial`     | `SIR`                        |              |                   |                   |
| `infections`  | `Vector{AbstractInfection}`  |              |                   | ordered list      |
| `removals`    | `Vector{AbstractRemoval}`    |              |                   | ordered list      |
| `cremovals`   | `Vector{CRemoval}`           |              |                   | ordered list      |
| `chronology`  | `Vector{AbstractIncident}`   | **computed** |                   | ordered list      |
| `trajectory`  | `Vector{SIR}`                | **computed** |                   | ordered list      |
| `history`     | `Vector{AbstractIncident}`   | **computed** |                   | ordered list      |
| `start`       | `Vector{AbstractInfection}`  | **computed** |                   | list              |
| `finis`       | `Vector{AbstractRemoval}`    | **computed** |                   | list              |
| `LFE `        | `Vector{SIR}`                | **computed** | `CEvolution`      | ordered list      |
| `envelope0`   | `Vector{Real}`               | **computed** | `CEvolution`      | ordered list      |
| `envelope`    | `Vector{Real}`               | **computed** | `CEvolution`      | ordered list      |

#### Unconditioned `Evolution`

```@docs
Evolution
Evolution(::SIR, ::Innovation)
Evolution(::SIR, ::Vector{AbstractIncident})
```

#### Conditioned `CEvolution`
```@docs
CEvolution
```

