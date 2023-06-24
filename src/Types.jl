## Types for various incidents.
"""
    AbstractTimedOccurrence

Represents an abstract incident or a state as occurring
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

## AbstractIncidents representing removals and infections

"""
    AbstractMarker

Represents an abstract marker for the epidemic graph using a sub-type of `AbstractIncident`.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  Normally this field `t`
should be given by the duration of the epidemic simulation!
Also expects field `target<:Integer` which identifies the time-line being considered.

The marker should only arise as the result of a computation;
it should not be introduced by the user.

"""
abstract type AbstractMarker <: AbstractIncident end

"""
    AbstractRemoval

Represents an abstract removal using a sub-type of `AbstractIncident`.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects field `target<:Integer`.

If the potential removal is to become realized 
then `target` must index a time-line which is infectious just before time `t`.

"""
abstract type AbstractRemoval <: AbstractIncident end

"""
    AbstractInfection

Represents an abstract infection using a sub-type of `AbstractIncident`.
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


## Various kinds of marker

"""
    InitialRemoved(t::Real, target::Integer)

Implements a marker for a time-line initially removed using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline indicated by the marker incident: it must be a positive integer.  
The `InitialRemoved` is realized if the specified timeline is removed at (initial) time `0`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> InitialRemoved(0.1, 4)
↦ℛ₀.₁₀⁴
```
"""
struct InitialRemoved <: AbstractMarker
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

Implements a marker for a time-line initially infectious using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline indicated by the marker incident: it must be a positive integer.  
The `InitialInfected` is realized if the specified timeline is infectious at (initial) time `0`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> InitialInfected(0.1, 4)
↦ℐ₀.₁₀⁴
```
"""
struct InitialInfected <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function InitialInfected(t, target)
        noun = "InitialInfected($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↦ℐ", t, target))
    end
end


"""
    InitialSusceptible(t::Real, target::Integer)

Implements a marker for a time-line initially susceptible using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline indicated by the marker incident: it must be a positive integer.  
The `InitialSusceptible` is realized if the specified timeline is susceptible at (initial) time `0`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> InitialSusceptible(0.1, 4)
↦𝒮₀.₁₀⁴
```
"""
struct InitialSusceptible <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function InitialSusceptible(t, target)
        noun = "InitialSusceptible($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↦𝒮", t, target))
    end
end



"""
    MarkerInfectionA(t::Real, target::Integer)

Implements a marker for a time-line becoming infectious using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline infected by the marker incident: it must be a positive integer.  
The `MarkerInfectionA` is realized if the specified timeline transits from top infection timeline at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> MarkerInfectionA(0.1, 4)
⮥ℐ₀.₁₀⁴
```
"""
struct MarkerInfectionA <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function MarkerInfectionA(t, target)
        noun = "MarkerInfectionA($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("⮥ℐ", t, target))
    end
end


"""
    MarkerInfectionB(t::Real, target::Integer)

Implements a marker for a time-line becoming infection using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline infected by the marker incident: it must be a positive integer.  
The `MarkerInfectionB` is realized if the specified timeline becomes top infection timeline at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> MarkerInfectionB(0.1, 4)
⮣ℐ₀.₁₀⁴
```
"""
struct MarkerInfectionB <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function MarkerInfectionB(t, target)
        noun = "MarkerInfectionB($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("⮣ℐ", t, target))
    end
end


"""
    MarkerRemovalA(t::Real, target::Integer)

Implements a marker for ongoing removal using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `MarkerRemovalA` is realized if the specified timeline transits from top removed timeline at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> MarkerRemovalA(0.1, 4)
⮥ℛ₀.₁₀⁴
```
"""
struct MarkerRemovalA <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function MarkerRemovalA(t, target)
        noun = "MarkerRemovalA($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("⮥ℛ", t, target))
    end
end



"""
    MarkerRemovalB(t::Real, target::Integer)

Implements a marker for ongoing removal using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `MarkerRemovalB` is realized if the specified timeline becomes top removed timeline at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> MarkerRemovalB(0.1, 4)
⮣ℛ₀.₁₀⁴
```
"""
struct MarkerRemovalB <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function MarkerRemovalB(t, target)
        noun = "MarkerRemovalB($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("⮣ℛ", t, target))
    end
end


"""
    ContinuingSusceptible(t::Real, target::Integer)

Implements a marker for ongoing susceptibility using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `ContinuingSusceptible` is realized if the specified timeline is susceptible at (final) time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> ContinuingSusceptible(0.1, 4)
↠𝒮₀.₁₀⁴
```
"""
struct ContinuingSusceptible <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function ContinuingSusceptible(t, target)
        noun = "ContinuingSusceptible($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↠𝒮", t, target))
    end
end

"""
    ContinuingInfected(t::Real, target::Integer)

Implements a marker for ongoing infection using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `ContinuingInfected` is realized if the specified timeline is infectious at (final) time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> ContinuingInfected(0.1, 4)
↠ℐ₀.₁₀⁴
```
"""
struct ContinuingInfected <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function ContinuingInfected(t, target)
        noun = "ContinuingInfected($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↠ℐ", t, target))
    end
end



"""
    ContinuingRemoved(t::Real, target::Integer)

Implements a marker for ongoing removal using a sub-type of `AbstractMarker`.  
The `target` field labels the timeline being considered as host for the marker incident: it must be a positive integer.  
The `ContinuingRemoved` is realized if the specified timeline is susceptible at (final) time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> ContinuingRemoved(0.1, 4)
↠ℛ₀.₁₀⁴
```
"""
struct ContinuingRemoved <: AbstractMarker
    kind      ::String     
    t         ::Float64
    target    ::Int

    function ContinuingRemoved(t, target)
        noun = "ContinuingRemoved($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("↠ℛ", t, target))
    end
end



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
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
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
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
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
        if infectee <= target
            throw(DomainError(noun, "disordered marks"))
        elseif target <= 0
            throw(DomainError(noun, "non-positive mark(s)"))
        else
            new("ℐ", t, target, infectee)
        end
    end
end

"""
    PInfection(t::Real, infector::Integer, target::Integer)

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
        if infectee <= target
            throw(DomainError(noun, "disordered marks"))
        elseif target <= 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒫", t, target, infectee)
        end
    end
end


"""
    AbstractEnvironment

Represent an entire innovation of environment for a single step of algorithmic time.

Should always possess field `n` (positive `Integer`) and
`infections`, `removals`, `cremovals (`Vector{AbstractIncident}`),
but displays `n` together with `infections`, `removals`, `cremovals` as 
**time-ordered** lists of corresponding incidents.
"""
abstract type AbstractEnvironment end

"""
    Innovation(n::Integer, infections::Vector{<:AbstractInfection},
                           removals::Vector{Removal},
                           cremovals::Vector{CRemoval})

Represent an entire innovation
corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals).

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
n = 3 ;
infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;
removals   = [Removal(0.2, 3), Removal(0.1, 2)] ;
cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 2)] ;
Innovation(n, infections, removals, cremovals)

# output
Innovation(3,
  AbstractInfection[𝒫₀.₅₀¹⁻², ℐ₀.₇₀¹⁻²],
  Removal[ℛ₀.₁₀², ℛ₀.₂₀³],
  CRemoval[𝒞₀.₀₀¹, 𝒞₀.₀₅²])
```
"""
struct Innovation <: AbstractEnvironment
    n::Int
    infections::Vector{<:AbstractInfection}
    removals::Vector{Removal}
    cremovals::Vector{CRemoval}

    function Innovation(n::Integer, infections::Vector{<:AbstractInfection},
                                    removals::Vector{Removal},
                                    cremovals::Vector{CRemoval})
        noun = "Innovation(n, $infections, $removals, $cremovals)"
        if n <= 0
            throw(DomainError(noun, "non-positive population size n"))
        elseif length(cremovals) > n
            throw(ArgumentError("too many conditional removals in \n$noun"))
        elseif any(cr.target > n for cr in cremovals)
            throw(ArgumentError("some conditional removal timelines too high in \n$noun"))
        elseif any(r.target > n for r in removals)
            throw(ArgumentError("some removal timelines too high in \n$noun"))
        elseif any(i.target > n for i in infections)
            throw(ArgumentError("some infection targets too high in \n$noun"))
        else
            new(n, sort(infections, lt=isearlier), 
                   sort(removals,   lt=isearlier), 
                   sort(cremovals,  lt=isearlier))
        end
    end
end

        
        
## An `SIR` state for an S-I-R epidemic and associated functions
"""
    SIR(t::Real, s::Integer, i::Integer, r::Integer)

Represent a state of an S-I-R epidemic (`s`, `i`, `r`)
(all non-negative integers adding up to a positive integer
which is the population size)
at a specified time `t` (a real number).

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

    function SIR(t, s, i, r)
        noun = "SIR($t, $s, $i, $r)"
        if s < 0
            throw(DomainError(noun, "negative number $s of susceptibles"))
        elseif i < 0
            throw(DomainError(noun, "negative number $i of infectives"))
        elseif r < 0
            throw(DomainError(noun, "negative number $r of removals"))
        elseif s + i + r == 0
            throw(DomainError(noun, "zero total population"))
        else
            new(t, s, i, r)
        end
    end
end
