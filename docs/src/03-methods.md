
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

| Method                                     | Summary                                                           |
|:-------------------------------------------|:------------------------------------------------------------------|
| [`generate_innovation`](@ref)              | Generates random [`Innovation`](@ref)                             |
| [`evolution`](@ref)                        | Generates trajectory and history for an [`Evolution`](@ref)       |
|                                            |                                                                   |
| [`EpidemicsCFTP.periods`](@ref)            | Computes start and end times for infectious periods               |
| [`EpidemicsCFTP.inactive_removals`](@ref)  | Processes list of inactive removals from an epidemic              |
| [`EpidemicsCFTP.accept_reject`](@ref)      | Performs accept/reject procedure on a proposed [`CRemoval`](@ref) |
| [`EpidemicsCFTP.resulting_cremovals`](@ref)| Determine set of re-sampled [`CRemoval`](@ref)s                   |
| [`EpidemicsCFTP.kill_irrelevant_infections`](@ref) | Kill new [`Infection`](@ref)s occurring in removal zone   |
| [`EpidemicsCFTP.kill_irrelevant_removals`](@ref)   | Kill new [`Removal`](@ref)s occurring in removal zone     |
| [`EpidemicsCFTP.relevant_infections`](@ref)| Identify new [`Infection`](@ref)s relevant to LFE                 |
|                                            |                                                                   |
| [`EpidemicsCFTP.antecedent`](@ref)         | Computes state before stated incident (no checks!)                |
| [`EpidemicsCFTP.reverse_update`](@ref)     | Performs reverse update if this is possible                       |
| [`EpidemicsCFTP.last_feasible_evolution`](@ref)    | Computes last feasible evolution (LFE)                    |
```@docs 
generate_innovation
evolution
EpidemicsCFTP.periods
EpidemicsCFTP.inactive_removals
EpidemicsCFTP.accept_reject
EpidemicsCFTP.kill_irrelevant_infections
EpidemicsCFTP.kill_irrelevant_removals
EpidemicsCFTP.relevant_infections
EpidemicsCFTP.antecedent
EpidemicsCFTP.reverse_update
EpidemicsCFTP.last_feasible_evolution
```

The second set of methods is a set of utility methods which are
employed in the course of applying [`evolution`]( to generate trajectory and history
in the course of initializing an [`Innovation`](@ref):

| Method                                 | Summary                                                            |
|:---------------------------------------|:-------------------------------------------------------------------|
| [`EpidemicsCFTP.is_activatable`](@ref) | Checks whether an [`AbstractIncident`](@ref) can be activated      |
| [`EpidemicsCFTP.infect`](@ref)         | Activates an [`Infection`](@ref)                                   |
| [`EpidemicsCFTP.remove`](@ref)         | Activates a [`Removal`](@ref)                                      |
| [`EpidemicsCFTP.is_same_config`](@ref) | Tests whether two [`SIR`](@ref) agree up to but not including time |
| [`EpidemicsCFTP.update`](@ref)         | Updates an [`SIR`](@ref), given an [`AbstractIncident`](@ref)`     |
```@docs
EpidemicsCFTP.is_activatable
EpidemicsCFTP.infect
EpidemicsCFTP.remove
EpidemicsCFTP.is_same_config
EpidemicsCFTP.update
```
