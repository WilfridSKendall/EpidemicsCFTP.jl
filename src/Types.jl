## Types for various incidents.
"""
    AbstractTimedOccurrence

This represents an abstract incident or a state as occurring
at a time specified by a `Real` number `t`.

Expects field `t<:Real` (used by function `isearlier`
to time-order lists of `AbstractTimedOccurrence` entities).
"""
abstract type AbstractTimedOccurrence end

"""
    AbstractIncident

Sub-type of `AbstractTimedOccurrence`.

Expects field `kind<:String` (used by function `show`
to represent the particular kind of incident).
"""
abstract type AbstractIncident <: AbstractTimedOccurrence end

## AbstractIncidents representing removals and infections and their markers

"""
    AbstractRemoval

This represents an abstract removal using a sub-type of `AbstractIncident`.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects field `target<:Integer`.

If the potential removal is to become realized 
then `target` must index a time-line which is infectious just before time `t`.

"""
abstract type AbstractRemoval <: AbstractIncident end

"""
    AbstractInfection

This represents an abstract infection using a sub-type of `AbstractIncident`.
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects fields `target<:Integer` and `infectee<:Integer`,
such that `target < infectee`.

If the potential infection is to become realized 
then `target` must index a time-line which is infectious, 
and `infectee` must index the susceptible time-line of smallest
index, both measured just before time `t`.

In particular, if there is no timeline which is susceptible
just before time `t` then the infection cannot be realized
whatever the value of `target`.

"""
abstract type AbstractInfection <: AbstractIncident end


"""
    AbstractMarker

This represents an abstract marker for the epidemic graph using a sub-type of `AbstractIncident`.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  Normally this field `t`
should be given by the duration of the epidemic simulation!
Also expects field `target<:Integer` which identifies the time-line being considered.

The marker should only arise as the result of a computation;
it should not be introduced by the user.

"""
abstract type AbstractMarker <: AbstractIncident end

"""
    AbstractSusceptibleMarker

A specialization of `AbstractMarker` relating to susceptibles.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  Normally this field `t`
should be given by the duration of the epidemic simulation!
Also expects field `target<:Integer` which identifies the time-line being considered.

The marker should only arise as the result of a computation;
it should not be introduced by the user.

"""
abstract type AbstractSusceptibleMarker <: AbstractMarker end

"""
    AbstractInfectionMarker

A specialization of `AbstractMarker` relating to infections.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  Normally this field `t`
should be given by the duration of the epidemic simulation!
Also expects field `target<:Integer` which identifies the time-line being considered.

The marker should only arise as the result of a computation;
it should not be introduced by the user.

"""
abstract type AbstractInfectionMarker <: AbstractMarker end

"""
    AbstractRemovalMarker

A specialization of `AbstractMarker` relating to removals.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  Normally this field `t`
should be given by the duration of the epidemic simulation!
Also expects field `target<:Integer` which identifies the time-line being considered.

The marker should only arise as the result of a computation;
it should not be introduced by the user.

"""
abstract type AbstractRemovalMarker <: AbstractMarker end


## Various kinds of removal

"""
    Removal(t::Real, target::Integer)

Implements a potential removal using a sub-type of `AbstractRemoval`.  
The `target` field labels the timeline being considered as host for the removal incident: it must be a positive integer.  
The `Removal` is realized if the specified timeline is infectious just before time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Removal(0.1, 4)
ℛ₀.₁₀⁴
```
"""
struct Removal <: AbstractRemoval
    kind      ::String     
    t         ::Float64
    target    ::Int

    function Removal(t, target)
        noun = "Removal($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("ℛ", t, target))
    end
end


"""
    CRemoval(t::Real, target::Integer)

Represent a conditioned removal using a sub-type of `AbstractRemoval`, similar to `Removal`.
The `target` field should always index a time-line which is currently infectious 
(a deterministic constraint, since the epidemic is conditional on observation of the times of all removals).

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> CRemoval(0.1, 4)
𝒞₀.₁₀⁴
```
"""
struct CRemoval <: AbstractRemoval
    kind      ::String     
    t         ::Float64
    target    ::Int

    function CRemoval(t, target)
        noun = "CRemoval($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("𝒞", t, target))
    end
end


## Various kinds of infection

"""
    Infection(t::Real, infectee::Integer, target::Integer)

Represent a potential infection using a sub-type of `AbstractInfection`,
using mark time `t` and another mark `target` and a further mark `infectee`.
Marks `target` and `infectee` must be positive integers with `target < infectee`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Infection(0.2, 1, 2)
ℐ₀.₂₀¹⁻²
```
"""
struct Infection <: AbstractInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int

    function Infection(t, target, infectee)
        noun = "Infection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark(s)"))
        else
            new("ℐ", t, target, infectee)
        end
    end
end

"""
    PInfection(t::Real, infectee::Integer, target::Integer)

Represent a perpetuated infection using a sub-type of `AbstractInfection`
which is identical to `Infection` but with a different name.

**CAN THIS BE DONE MORE NEATLY?**

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> PInfection(0.2, 1, 2)
𝒫₀.₂₀¹⁻²
```
"""
struct PInfection <: AbstractInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function PInfection(t, target, infectee)
        noun = "PInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒫", t, target, infectee)
        end
    end
end



## Various kinds of marker

"""
    InitialRemoved(t::Real, target::Integer)

Implements a marker for a initially removed time-line as a sub-type of `AbstractRemovalMarker`.  
The `target` field labels the timeline indicated by the marker incident: it must be a positive integer.  
The `InitialRemoved` is realized if the specified timeline is removed at (initial) time `0`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> InitialRemoved(0.1, 4)
↦ℛ₀.₁₀⁴
```
"""
struct InitialRemoved <: AbstractRemovalMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function InitialRemoved(t, target)
        noun = "InitialRemoved($t, $target)"
        (target < 0 ? throw(DomainError(noun, "negative mark")) :
                new("↦ℛ", t, target))
    end
end


"""
    InitialInfected(t::Real, target::Integer)

Implements a marker for an initially infectious time-line as a sub-type of `AbstractInfectionMarker`.  
The `target` field labels the timeline indicated by the marker incident: it must be a positive integer.  
The `InitialInfected` is realized if the specified timeline is infectious at (initial) time `0`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> InitialInfected(0.1, 4)
↦ℐ₀.₁₀⁴
```
"""
struct InitialInfected <: AbstractInfectionMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function InitialInfected(t, target)
        noun = "InitialInfected($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↦ℐ", t, target))
    end
end


"""
    InitialSusceptible(t::Real, target::Integer)

Implements a marker for an initially susceptible time-line as a sub-type of `AbstractSusceptibleMarker`.  
The `target` field labels the timeline indicated by the marker incident: it must be a positive integer.  
The `InitialSusceptible` is realized if the specified timeline is susceptible at (initial) time `0`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> InitialSusceptible(0.1, 4)
↦𝒮₀.₁₀⁴
```
"""
struct InitialSusceptible <: AbstractSusceptibleMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function InitialSusceptible(t, target)
        noun = "InitialSusceptible($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↦𝒮", t, target))
    end
end



"""
    MarkerInfectionA(t::Real, target::Integer)

Implements a marker for a time-line becoming infectious as a sub-type of `AbstractInfectionMarker`.  
The `target` field labels the timeline infected by the marker incident: it must be a positive integer.  
The `MarkerInfectionA` is realized if the specified timeline transits from top infection timeline at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> MarkerInfectionA(0.1, 4)
⮥ℐ₀.₁₀⁴
```
"""
struct MarkerInfectionA <: AbstractInfectionMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function MarkerInfectionA(t, target)
        noun = "MarkerInfectionA($t, $target)"
        (target < 0 ? throw(DomainError(noun, "negative mark")) :
                new("⮥ℐ", t, target))
    end
end


"""
    MarkerInfectionB(t::Real, target::Integer)

Implements a marker for a time-line becoming infection as a sub-type of `AbstractInfectionMarker`.  
The `target` field labels the timeline infected by the marker incident: it must be a positive integer.  
The `MarkerInfectionB` is realized if the specified timeline becomes top infection timeline at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> MarkerInfectionB(0.1, 4)
⮣ℐ₀.₁₀⁴
```
"""
struct MarkerInfectionB <: AbstractInfectionMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function MarkerInfectionB(t, target)
        noun = "MarkerInfectionB($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("⮣ℐ", t, target))
    end
end


"""
    MarkerRemovalA(t::Real, target::Integer)

Implements a marker for ongoing removal as a sub-type of `AbstractRemovalMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `MarkerRemovalA` is realized if the specified timeline transits from top removed timeline at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> MarkerRemovalA(0.1, 4)
⮥ℛ₀.₁₀⁴
```
"""
struct MarkerRemovalA <: AbstractRemovalMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function MarkerRemovalA(t, target)
        noun = "MarkerRemovalA($t, $target)"
        (target < 0 ? throw(DomainError(noun, "negative mark")) :
                new("⮥ℛ", t, target))
    end
end



"""
    MarkerRemovalB(t::Real, target::Integer)

Implements a marker for ongoing removal as a sub-type of `AbstractRemovalMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `MarkerRemovalB` is realized if the specified timeline becomes top removed timeline at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> MarkerRemovalB(0.1, 4)
⮣ℛ₀.₁₀⁴
```
"""
struct MarkerRemovalB <: AbstractRemovalMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function MarkerRemovalB(t, target)
        noun = "MarkerRemovalB($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("⮣ℛ", t, target))
    end
end


"""
    ContinuingSusceptible(t::Real, target::Integer)

Implements a marker for ongoing susceptibility as a sub-type of `AbstractSusceptibleMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `ContinuingSusceptible` is realized if the specified timeline is susceptible at (final) time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> ContinuingSusceptible(0.1, 4)
↠𝒮₀.₁₀⁴
```
"""
struct ContinuingSusceptible <: AbstractSusceptibleMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function ContinuingSusceptible(t, target)
        noun = "ContinuingSusceptible($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↠𝒮", t, target))
    end
end

"""
    ContinuingInfected(t::Real, target::Integer)

Implements a marker for ongoing infection as a sub-type of `AbstractInfectionMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `ContinuingInfected` is realized if the specified timeline is infectious at (final) time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> ContinuingInfected(0.1, 4)
↠ℐ₀.₁₀⁴
```
"""
struct ContinuingInfected <: AbstractInfectionMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function ContinuingInfected(t, target)
        noun = "ContinuingInfected($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↠ℐ", t, target))
    end
end



"""
    ContinuingRemoved(t::Real, target::Integer)

Implements a marker for ongoing removal as a sub-type of `AbstractRemovalMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `ContinuingRemoved` is realized if the specified timeline is susceptible at (final) time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> ContinuingRemoved(0.1, 4)
↠ℛ₀.₁₀⁴
```
"""
struct ContinuingRemoved <: AbstractRemovalMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function ContinuingRemoved(t, target)
        noun = "ContinuingRemoved($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↠ℛ", t, target))
    end
end

## Environments and trajectories

"""
    AbstractEnvironment

Represents variants of an entire innovation of environment for a single step of algorithmic time.

Should always possess field `population` (positive `Integer`) and
`infections`, `removals`, `cremovals (`Vector{AbstractIncident}`),
but displays `population` together with `infections`, `removals`, `cremovals` as 
**time-ordered** lists of corresponding incidents.
"""
abstract type AbstractEnvironment end

"""
    Innovation(population::Integer, infections::Vector{T},
               removals::Vector{Removal},
               cremovals::Vector{CRemoval}) where T<:AbstractInfection

This represents an entire innovation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals).

Note that there is a computed field `chronology` holding a
time-ordered list of the incidents in `infections`, `removals`, and `cremovals`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
population = 3 ;
infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;
removals   = [Removal(0.2, 3), Removal(0.1, 2)] ;
cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 2)] ;
Innovation(population, infections, removals, cremovals)

# output
Innovation(3,
  AbstractInfection[𝒫₀.₅₀¹⁻², ℐ₀.₇₀¹⁻²],
  Removal[ℛ₀.₁₀², ℛ₀.₂₀³],
  CRemoval[𝒞₀.₀₀¹, 𝒞₀.₀₅²])
```
"""
struct Innovation <: AbstractEnvironment
    population ::Int
    infections ::Vector{<:AbstractInfection}
    removals   ::Vector{Removal}
    cremovals  ::Vector{CRemoval}
    chronology ::Vector{<:AbstractIncident}

    function Innovation(population::Integer, infections::Vector{T},
                        removals::Vector{Removal},
                        cremovals::Vector{CRemoval}) where T<:AbstractInfection
        noun = "Innovation($population, $infections, $removals, $cremovals)"
        if population ≤ 0
            throw(DomainError(noun, "non-positive population size $population"))
        elseif length(cremovals) > population
            throw(ArgumentError("too many conditional removals in \n$noun"))
        elseif any(cr.target > population for cr in cremovals)
            throw(ArgumentError("some conditional removal timelines too high in \n$noun"))
        elseif any(r.target > population for r in removals)
            throw(ArgumentError("some removal timelines too high in \n$noun"))
        elseif any(i.target > population for i in infections)
            throw(ArgumentError("some infection targets too high in \n$noun"))
        else
            chron = Iterators.flatten([infections, removals, cremovals])
            new(population, sort(infections, lt=isearlier), 
                sort(removals,   lt=isearlier), 
                sort(cremovals,  lt=isearlier),
                [x::AbstractIncident for x in sort(collect(chron), lt=isearlier)])
        end
    end

    function Innovation(population::Integer, infections::Vector{T},
                        removals::Vector{Removal}) where T<:AbstractInfection
        Innovation(population, infections, removals, CRemoval[])
    end
    
end


## An `SIR` state for an $\SIR$ epidemic and associated functions
"""
    SIR(t::Real, s::Integer, i::Integer, r::Integer)

This represents a state of an S-I-R epidemic (`s`, `i`, `r`)
(all non-negative integers adding up to a positive integer `n`
which is the population size, given by the computed field `population`)
at a specified time `t` (a real number). Note that `n` can be computed
at initialization of the state structure: just call `SIR(s,i,r)`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> SIR(0.1, 1, 2, 3)
SIR₀.₁₀(1:2:3)
```
"""
struct SIR <: AbstractTimedOccurrence
    t::Float64
    s::Int
    i::Int
    r::Int
    n::Int

    function SIR(t, s, i, r, n)
        noun = "SIR($t, $s, $i, $r)"
        if s < 0
            throw(DomainError(noun, "negative number $s of susceptibles"))
        elseif i < 0
            throw(DomainError(noun, "negative number $i of infectives"))
        elseif r < 0
            throw(DomainError(noun, "negative number $r of removals"))
        elseif s + i + r == 0
            throw(DomainError(noun, "zero total computed population"))
        elseif s + i + r != n
            throw(DomainError(noun, "population n=$n is not sum of s=$s, i=$i, r=$r"))
        else
            new(t, s, i, r, n)
        end
    end

    function SIR(t, s, i, r)
        n = s + i + r
        SIR(t, s, i, r, n)
    end

end

## Structures capturing $SIR$ epidemics

"""
    `AbstractEvolution` 

This represents variants of evolution of an `S-I-R` epidemic..

It should always possess fields `population` (positive `Integer`),
`infections`, `removals`, `cremovals (`Vector{AbstractIncident}`),
and computed `chronology`, `trajectory` and `history`.
"""
abstract type AbstractEvolution <: AbstractEnvironment end

"""
    `BadIncident`

An exception to report misuse of an incident.
"""
abstract type BadIncident <: Exception end
        
"""
    `MissedCRemoval`

This is an exception encountered when a `CRemoval` is missed by
`evolution`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
population = 3 ;
infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;
removals   = [Removal(0.2, 3), Removal(0.1, 2)] ;
cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 1)] ;
innov      = Innovation(population, infections, removals, cremovals) ;
initial    = SIR(0.0, 2, 1, 0)
CEvolution(initial, innov)

# output
ERROR: The (conditioned) evolution misused 𝒞₀.₀₅¹
```
"""
struct MissedCRemoval <: BadIncident
    incident ::AbstractIncident
end

"""
    `EmployedRemoval`

This is an exception encountered when a `Removal` is not missed by
`evolution`.
```
"""
struct EmployedRemoval <: BadIncident
    incident ::AbstractIncident
end

"""
    Evolution(initial_state::SIR, innovation::Innovation)

This implements _unconditional_ evolution of an SIR epidemic 
based on a given `Innovation` 
for innovations,
and starting from a given `SIR` for initial state.

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals)
and also computed fields `chronology`, `trajectory` and `history`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
population = 3 ;
infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;
removals   = [Removal(0.2, 3), Removal(0.1, 2)] ;
cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 2)] ;
innov      = Innovation(population, infections, removals, cremovals) ;
initial    = SIR(0.0, 2, 1, 0)
Evolution(initial, innov)

# output
Evolution(3,
  AbstractInfection[𝒫₀.₅₀¹⁻², ℐ₀.₇₀¹⁻²],
  Removal[ℛ₀.₁₀², ℛ₀.₂₀³],
  CRemoval[𝒞₀.₀₀¹, 𝒞₀.₀₅²]
  AbstractIncident[𝒞₀.₀₀¹, 𝒞₀.₀₅², ℛ₀.₁₀², ℛ₀.₂₀³, 𝒫₀.₅₀¹⁻², ℐ₀.₇₀¹⁻²]
  SIR[SIR₀.₀₀(2:1:0), SIR₀.₀₀(2:0:1)]
  AbstractIncident[𝒞₀.₀₀¹])
```
"""
struct Evolution <: AbstractEvolution
    population ::Int
    infections ::Vector{<:AbstractInfection}
    removals   ::Vector{Removal}
    cremovals  ::Vector{CRemoval}
    chronology ::Vector{<:AbstractIncident}
    trajectory ::Vector{SIR}
    history    ::Vector{AbstractIncident}
    
    function Evolution(initial_state::SIR, innovation::Innovation)
        # Need to check population == sum of initiate.state entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation)
        new(population, infections, removals, cremovals, chronology, trajectory, history)
    end
end

"""
    CEvolution(initial_state::SIR, innovation::Innovation)

This implements _conditional_ evolution of an SIR epidemic 
based on a given `Innovation` 
for innovations,
and starting from a given `SIR` for initial state.

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals)
and also computed fields `chronology`, `trajectory` and `history`.

## Example
Three cases: straightforward, missing a conditioned removal, employing an (unconditioned) removal:
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial    = SIR(0.0, 2, 1, 0) ;

julia> population = 3 ;

julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;

julia> removals   = [Removal(0.2, 3), Removal(0.1, 2)] ;

julia> cremovals  = [CRemoval(0.0, 1)] ;

julia> innov      = Innovation(population, infections, removals, cremovals) ;

julia> CEvolution(SIR(0.0, 2, 1, 0), innov)
CEvolution(3,
  AbstractInfection[𝒫₀.₅₀¹⁻², ℐ₀.₇₀¹⁻²],
  Removal[ℛ₀.₁₀², ℛ₀.₂₀³],
  CRemoval[𝒞₀.₀₀¹]
  AbstractIncident[𝒞₀.₀₀¹, ℛ₀.₁₀², ℛ₀.₂₀³, 𝒫₀.₅₀¹⁻², ℐ₀.₇₀¹⁻²]
  SIR[SIR₀.₀₀(2:1:0), SIR₀.₀₀(2:0:1)]
  AbstractIncident[𝒞₀.₀₀¹])

julia> cremovals  = [CRemoval(0.0, 2)] ;

julia> innov      = Innovation(population, infections, removals, cremovals) ;

julia> CEvolution(initial, innov)
ERROR: The (conditioned) evolution misused 𝒞₀.₀₀²

julia> removals   = [Removal(0.1, 1), Removal(0.1, 2)] ;

julia> cremovals  = [CRemoval(0.2, 1)] ;

julia> innov      = Innovation(population, infections, removals, cremovals) ;

julia> CEvolution(initial, innov)
ERROR: The (conditioned) evolution misused ℛ₀.₁₀¹
```
"""
struct CEvolution <: AbstractEvolution
    population ::Int
    infections ::Vector{<:AbstractInfection}
    removals   ::Vector{Removal}
    cremovals  ::Vector{CRemoval}
    chronology ::Vector{<:AbstractIncident}
    trajectory ::Vector{SIR}
    history    ::Vector{AbstractIncident}
    
    function CEvolution(initial_state::SIR, innovation::Innovation)
        # Need to check population == sum of initiate.state entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation, conditioned=true)
        new(population, infections, removals, cremovals, chronology, trajectory, history)
    end
end
