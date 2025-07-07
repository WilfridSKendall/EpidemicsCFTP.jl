# Types

```@setup CFTP
using EpidemicsCFTP, EpidemicsCFTP.abbreviations
using EpidemicsUtilities
import EpidemicsUtilities: ACTIVATED, REGIONS, BOUNDARIES, BASIC, ELEMENTS, LFE, LFET, LFER, MOST, NFZ

const duration = 2.0;
const α, β     = 0.2, 1.5;
const initial  = SIR(0.0, 5, 1, 0);

include("../src/graphics-setup.jl")
```

## Abstract timed occurrences
Most entities of `EpidemicsCFTP` are based on the generic type [`AbstractTimedOccurrence`](@ref).
The only requirement on objects of this type is that they should possess
a real-valued attribute `t` corresponding to a (process) time.
```@docs
AbstractTimedOccurrence
```
The type [`AbstractTimedOccurrence`](@ref) 
has sub-types `AbstractIncident` 
(whose sub-types correspond to various kinds of _possible_ infections and removals)
and `SIR` 
(representing the state of the `S-I-R` 
incident at a particular moment of time). 
```@docs
EpidemicsCFTP.TextualRepresentation
```


### The state of an epidemic
The purpose of the type `SIR` is 
to provide a structure for recording the state of a `S-I-R` epidemic at a stipulated time, based on [`AbstractTimedOccurrence`](@ref).
```@docs
SIR
```

### Abstract incidents
`AbstractIncident` is a generic type for incidents taking place in time, derived from [`AbstractTimedOccurrence`](@ref).
```@docs
AbstractIncident
```

The type [`AbstractIncident`](@ref) has sub-types
[`AbstractRemoval`](@ref) and [`AbstractInfection`](@ref), generic incidents corresponding
to potential removals and potential incidents respectively. Figure 4.1
provides a visual key to the various concrete sub-types of 
[`AbstractRemoval`](@ref) and [`AbstractInfection`](@ref).

```@example CFTP
set_default_plot_size(theme.figwidth, 0.6theme.figheight)          # hide
key_template = plot(yintercept=1:3,                                # hide
    Geom.hline(style=:dash, size=0.1mm, color=theme.scaffold),     # hide
    Coord.cartesian(xmin=0, xmax=3, ymin=0.5, ymax=3 + 0.25),      # hide
    style(default_color=theme.background),                         # hide
    gadfly_theme) ;                                                # hide
                                                                   # hide
key_template = new_figure(key_template,                            # hide
    Scale.y_continuous(labels=(i ->                                # hide
            EpidemicsUtilities.timelinelabel_raw(i; n=initial.n))),# hide
    Guide.yticks(ticks=collect(1:3)),                              # hide
    ) ;                                                            # hide
                                                                   # hide
push!(key_template, Scale.y_continuous(                            # hide
        labels=(initial.n ≤ EpidemicsUtilities.MAXPOP ?            # hide
        i -> EpidemicsUtilities.timelinelabels_circled(i; n=initial.n) : # hide
        i -> EpidemicsUtilities.timelinelabels_bracketed(i; n=initial.n))), # hide
    ) ;                                                            # hide
                                                                   # hide
x, dx = 0.1, 0.18                                                  # hide
x1    = x + 0.5dx                                                  # hide
                                                                   # hide
# Do the next figure programmatically!                             # hide
depict("key", new_figure(key_template,                             # hide
    Guide.annotation(compose(context(),                            # hide
        draw_elements([I(x,1,3), P(x+2dx,2,3),                     # hide
            NoFlyInfection(x+4dx,1,3),                             # hide
            ExpungedInfection(x+6dx,2,3),                          # hide
            KilledInfection(x+8dx,1,3),                            # hide
            R(x+10dx,2),                                           # hide
            KilledRemoval(x+12dx,1),                               # hide
            C(x+14dx,2)], theme=theme),                            # hide
        draw_elements([I(x+dx,1,3),                                # hide 
            P(x+3dx,2,3),                                          # hide
            NoFlyInfection(x+5dx,1,3),                             # hide
            ExpungedInfection(x+7dx,2,3),                          # hide
            KilledInfection(x+9dx,1,3),                            # hide
            R(x+11dx,2),                                           # hide
            KilledRemoval(x+13dx,1),                               # hide
            C(x+15dx,2)], theme=theme),                            # hide
        draw_elements([I(x+dx,1,3),                                # hide 
            P(x+3dx,2,3),                                          # hide
            NoFlyInfection(x+5dx,1,3),                             # hide
            ExpungedInfection(x+7dx,2,3),                          # hide
            KilledInfection(x+9dx,1,3),                            # hide
            R(x+11dx,1),                                           # hide
            KilledRemoval(x+13dx,2),                               # hide
            C(x+15dx,1)], activated=true, theme=theme),            # hide
        )),                                                        # hide
    Guide.annotation(compose(context(),                            # hide
        text(x1,      0.53, "Infection",          hcenter),        # hide
        text(x1+ 2dx, 0.35, "PInfection",         hcenter),        # hide
        text(x1+ 4dx, 0.53, "NoFlyInfection",     hcenter),        # hide
        text(x1+ 6dx, 0.35, "ExpungedInfection",  hcenter),        # hide
        text(x1+ 8dx, 0.53, "KilledInfection",    hcenter),        # hide
        text(x1+10dx, 0.35, "Removal",            hcenter),        # hide
        text(x1+12dx, 0.53, "Killed Removal",     hcenter),        # hide
        text(x1+14dx, 0.35, "CRemoval",           hcenter),        # hide
        fontsize(6pt))),                                           # hide
    ), imagetype="pdfonly")                                        # hide
                                                                   # hide
set_default_plot_size(theme.figwidth, theme.figheight)             # hide
```

![Recognition chart for various varieties of abstract incidents.](image/key.pdf)

#### `AbstractRemoval`
`AbstractRemoval` is a generic sub-type of [`AbstractIncident`](@ref),
itself possessing generic sub-types
[`OperativeRemoval`](@ref) and [`NonOperativeRemoval`](@ref), used to distinguish between
potential removal incidents
according to whether or not they may form part of 
an epidemic trajectory.

Concrete sub-types are tabulated as follows:

| _Type of `AbstractRemoval`_ | _Immediate parent type_       | _Explanation_                              |
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
`Removal` and `CRemoval` represent specific potential removal incidents: 
`CRemoval` is reserved for realized removals (which in our application
are always conditioned to happen).
```@docs
Removal
CRemoval
CRemoval(::AbstractRemoval)
```
#### Two kinds of [`NonOperativeRemoval`](@ref)
`KilledRemoval` and `RemovalMarker` are further kinds of removal which will _never_ be realized.
`RemovalMarker` occurs at the end of the epidemic for a time line which is never removed.
```@docs
KilledRemoval
KilledRemoval(::AbstractRemoval)
RemovalMarker
RemovalMarker(::AbstractRemoval)
```

### `AbstractInfection`
`AbstractInfection` incidents are sub-typed as
[`OperativeInfection`](@ref) and [`NonOperativeInfection`](@ref),
used to distinguishes between
potential infection incidents
according to whether or not they are allowed to form part of 
an epidemic trajectory.

Concrete sub-types are tabulated as follows:

| _Type of `AbstractInfection`_ | _Immediate parent type_       | _Explanation_                               |
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
Infection(::AbstractInfection)
PInfection
PInfection(::AbstractInfection)
NoFlyInfection
NoFlyInfection(z::AbstractInfection)
```

#### Three different kinds of `NonOperativeInfection`s
`KilledInfection`,
`ExpungedInfection`,
`InfectionMarker`are specific non-operative infection incidents as tabulated.
They are _never_ realized!
`InfectionMarker` occurs at the start of the epidemic for a time line which is initially infected.

```@docs
KilledInfection
KilledInfection(::AbstractInfection)
ExpungedInfection
ExpungedInfection(::ExpungedInfection)
InfectionMarker
InfectionMarker(::InfectionMarker)
```

### Abbreviations for `AbstractIncident`s
It is often helpful to import or use the submodule `.abbreviations` in `EpidemicsCFTP`.
```@docs
EpidemicsCFTP.abbreviations
```


## Representing different kinds of environments
`AbstractEnvironment` is a generic type for a collection of lists of `infections`,
`removals` and `cremovals` (conditioned removals).
There are two abstract sub-types:
[`AbstractInnovation`](@ref)
and
[`AbstractEvolution`](@ref).

Instances should always possess fields as given in the table. 

| _Field name_ | _Type_                      |              | _Further remarks_                 |
|:-------------|:----------------------------|:-------------|:----------------------------------|
| `infections` | `Vector{AbstractInfection}` |              | ordered list                      |
| `removals`   | `Vector{AbstractRemoval}`   |              | ordered list                      |
| `cremovals`  | `Vector{CRemoval}`          |              | ordered list if nonempty          |
| `chronology` | `Vector{AbstractIncident}`  | **computed** | ordered union of previous 3 lists |

```@docs
AbstractEnvironment
AbstractInnovation
AbstractEvolution
```

### Two kinds of `AbstractInnovation`
[`AbstractInnovation`](@ref) has one subtype:
`Innovation` fills the lists of an abstract environment with (typically simulated) contents
of lists of the requisite infections or removals. 
Instances should always possess fields as given in the table. 

| _Field name_ | _Type_                      |              | _Further remarks_                 |
|:-------------|:----------------------------|:-------------|:----------------------------------|
| `infections` | `Vector{AbstractInfection}` |              | ordered list                      |
| `removals`   | `Vector{AbstractRemoval}`   |              | ordered list                      |
| `cremovals`  | `Vector{CRemoval}`          |              | ordered list if nonempty          |
| `chronology` | `Vector{AbstractIncident}`  | **computed** | ordered union of previous 3 lists |

```@docs
Innovation
Innovation(::Int, ::Vector{<:AbstractInfection}, ::Vector{<:AbstractRemoval}, ::Vector{CRemoval})
Innovation(::Int, ::Vector{<:AbstractInfection}, ::Vector{<:AbstractRemoval})
Innovation(::Int, ::Vector{AbstractIncident})
```

### Two kinds of `AbstractEvolution`
[`AbstractEvolution`](@ref) has two subtypes:
`Evolution` carries out the simulation of an epidemic from a given initial `SIR` value,
based on an [`Innovation`](@ref). 
`CEvolution` does the same, but returns an error if it violates conditioning 
in the way it treats [`AbstractRemoval`](@ref)s.
(This distinctive behaviour is implemented in the [`evolution`](@ref) function
when keyword `conditioned` is `true`.)


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
| `NFZ1`        | `Vector{Real}`               | **computed** | `CEvolution`      | ordered list      |
| `NFZ2`        | `Vector{Real}`               | **computed** | `CEvolution`      | ordered list      |
| `NFZ`         | `Vector{Real}`               | **computed** | `CEvolution`      | ordered list      |
| `size`        | `Int`                        | **keyword**  | `                 | ignored if `0`    |
| `t0`          | `Real`                       | **keyword**  | `                 | computed if `-∞`  |
| `duration`    | `Real`                       | **keyword**  | `                 | computed if `∞`   |

#### Unconditioned `Evolution`

```@docs
Evolution
Evolution(::SIR, ::Innovation)
Evolution(::SIR, ::Vector{AbstractIncident})
```

#### Conditioned `CEvolution`
```@docs
CEvolution
CEvolution(::AbstractEvolution, ::Innovation)
CEvolution(::SIR, ::Vector{AbstractIncident})
CEvolution(::SIR, ::Innovation)
```

#### Innovations for initial states
```@docs
AbstractInnovationStart
InnovationStart_IS
InnovationStart_IS(::Vector{<: Real}, ::Int)
InnovationStart_sRWM
InnovationStart_sRWM(::Vector{<: Real}, ::Real, ::Int)
InnovationStart_aRWM
InnovationStart_aRWM(::Vector{<: Real}, ::Real, ::Real, ::Int)
```
