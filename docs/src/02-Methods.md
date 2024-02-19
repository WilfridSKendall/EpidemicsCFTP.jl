# Methods for computation

## Helpful operators
Notation that is useful for concise expression of CFTP algorithms.
```@docs
⪯
≃
⋄
```

## A total ordering for incidents
A total ordering is provided by [`Base.isless`](@ref)
(with signature `isless(::AbstractIncident,::AbstractIncident)`), based on time `t` of occurrence of 
the two arguments, which should be 
instances of
[`AbstractIncident`](@ref)s.
```@docs
isless(::S, ::T) where {S <: AbstractInfection, T <: AbstractRemoval}
```

## Altering `CRemoval` targets
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

| _Method_                                   | _Summary_                                              |
|:-------------------------------------------|:-------------------------------------------------------|
| [`generate_innovation`](@ref)              | Generates random [`Innovation`](@ref)                  |
| [`evolution`](@ref)                        | Generates trajectory, history for [`Evolution`](@ref)  |
| [`evolution_history`](@ref)                | Generates history for [`Evolution`](@ref)              |
| [`extremal_evolution`](@ref)               | Generates extremal [`Evolution`](@ref) from `CRemoval`s|
|                                            |                                                        |
| [`EpidemicsCFTP.last_feasible_evolution`](@ref)    | Computes last feasible evolution (LFE)         |
| [`EpidemicsCFTP.compute_NFZ`](@ref)        | Computes adapted [`Infection`](@ref)s and nofly zone   |
| [`EpidemicsCFTP.interval`](@ref)           | Computes `start` and `finis` for infectious intervals  |
| [`EpidemicsCFTP.inactive_removals`](@ref)  | Processes list of inactive removals from an epidemic   |
| [`EpidemicsCFTP.accept_reject`](@ref)      | Performs accept/reject on proposed [`CRemoval`](@ref)  |
| [`EpidemicsCFTP.resulting_cremovals`](@ref)| Determine set of re-sampled [`CRemoval`](@ref)s        |
| [`EpidemicsCFTP.kill_irrelevant_infections`](@ref) | Kill new [`Infection`](@ref)s in removal zone  |
| [`EpidemicsCFTP.kill_irrelevant_removals`](@ref)   | Kill new [`Removal`](@ref)s in removal zone    |
| [`EpidemicsCFTP.relevant_infections`](@ref)| Identify new [`Infection`](@ref)s relevant to LFE      |
|                                            |                                                        |
| [`EpidemicsCFTP.antecedent`](@ref)         | Computes state before stated incident (no checks!)     |
| [`EpidemicsCFTP.reverse_update`](@ref)     | Performs reverse update if this is possible            |
```@docs 
generate_innovation
evolution
evolution_history
```

For purposes of CFTP we need to be able to generate initial _maximal_ or _minimal_ `CEvolution`s,
specified by the initial state and a list of times for `CRemoval`s.
```@docs 
extremal_evolution
```

```@docs 
EpidemicsCFTP.last_feasible_evolution
EpidemicsCFTP.compute_NFZ
EpidemicsCFTP.interval
EpidemicsCFTP.inactive_removals
EpidemicsCFTP.accept_reject
EpidemicsCFTP.resulting_cremovals
EpidemicsCFTP.kill_irrelevant_infections
EpidemicsCFTP.kill_irrelevant_removals
EpidemicsCFTP.relevant_infections
EpidemicsCFTP.antecedent
EpidemicsCFTP.reverse_update
```

The second set of methods is a set of utility methods which are
employed in the course of applying [`evolution`]( to generate trajectory and history
in the course of initializing an [`Innovation`](@ref):

| _Method_                               | _Summary_                                                  |
|:---------------------------------------|:-----------------------------------------------------------|
| [`EpidemicsCFTP.is_activatable`](@ref) | Checks whether [`AbstractIncident`](@ref) can be activated |
| [`EpidemicsCFTP.infect`](@ref)         | Activates an [`Infection`](@ref)                           |
| [`EpidemicsCFTP.remove`](@ref)         | Activates a [`Removal`](@ref)                              |
| [`EpidemicsCFTP.is_same_config`](@ref) | Tests whether two [`SIR`](@ref) agree except for time      |
| [`EpidemicsCFTP.update`](@ref)         | Updates [`SIR`](@ref), given [`AbstractIncident`](@ref)`   |
```@docs
EpidemicsCFTP.is_activatable
EpidemicsCFTP.infect
EpidemicsCFTP.remove
EpidemicsCFTP.is_same_config
EpidemicsCFTP.update
```
## Methods for debugging
| _Method_                               | _Summary_                                                   |
|:---------------------------------------|:------------------------------------------------------------|
| [`EpidemicsCFTP.is_correct_LFE`](@ref) | Checks whether `LFE` is indeed a _last_ feasible evolution! |
| [`EpidemicsCFTP.is_correct_NFZ3](@ref) | Checks whether `NFZ3` is indeed a valid no-fly zone!        |
```@docs
EpidemicsCFTP.is_correct_LFE
EpidemicsCFTP.is_correct_NFZ3
```
