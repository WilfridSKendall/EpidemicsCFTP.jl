## Types for various incidents.

"""
    AbstractIncident

Represents an abstract incident (infection or removal) at a time specified 
by a `Real` number `t`.  
Expects field `t<:Real` (will be used by function `isless` to time-order lists of `AbstractIncident` entities).
"""
abstract type AbstractIncident end

## AbstractIncidents representing removals and infections

"""
    AbstractRemoval

Represents an abstract removal using a sub-type of `AbstractIncident`.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects field `target<:Integer`.

If the potential infection is to become realized 
then `target` must index a time-line which is infectious just before time `t`.

"""
abstract type AbstractRemoval <: AbstractIncident end

"""
    AbstractInfection

Represents an abstract infection using a sub-type of `AbstractIncident`.
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects fields `infector<:Integer` and `infectee<:Integer`,
such that `infector < infectee`.

If the potential infection is to become realized 
then `infector` must index a time-line which is infectious, 
and `infectee` must index the susceptible time-line of smallest
index, both measured just before time `t`.

In particular, if there is no timeline which is susceptible
just before time `t` then the infection cannot be realized
whatever the value of `infectee`.

"""
abstract type AbstractInfection <: AbstractIncident end


## Various kinds of removal

"""
    Removal(t::Real, target::Integer)

Implements a potential removal using a sub-type of `AbstractRemoval`.  
The `target` field labels the timeline being considered as host for the removal incident: it must be a positive integer.  
The `Removal` is realized if the specified timeline is infectious just before time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Removal(0.1, 4)
R₀.₁₀(4)
```
"""
struct Removal <: AbstractRemoval
    t         ::Float64
    target    ::Int

    function Removal(t, target)
        noun = "Removal($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new(t, target))
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
C₀.₁₀(4)
```
"""
struct CRemoval <: AbstractRemoval
    t       ::Float64
    target  ::Int

    function CRemoval(t, target)
        noun = "CRemoval($t, $target)"
        (target <= 0 ? throw(DomainError(noun, "non-positive mark")) :
                new(t, target))
    end
end


## Various kinds of infection

"""
    Infection(t::Real, infector::Integer, infectee::Integer)

Represent a potential infection using a sub-type of `AbstractInfection`,
using mark time `t`, also specified marks `infector` and `infectee` timelines
which must be positive integers.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Infection(0.2, 1, 2)
I₀.₂₀(1,2)
```
"""
struct Infection <: AbstractInfection
    t::  Float64
    infector:: Int
    infectee:: Int
    function Infection(t, infector, infectee)
        noun = "Infection($t, $infector, $infectee)"
        if infectee <= infector
            throw(DomainError(noun, "disordered marks"))
        elseif infector <= 0
            throw(DomainError(noun, "non-positive mark(s)"))
        else
            new(t, infector, infectee)
        end
    end
end

"""
    PInfection(t::Real, infector::Integer, infectee::Integer)

Represent a perpetuated infection using a sub-type of `AbstractInfection`
which is identical to `Infection` but with a different name.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> PInfection(0.2, 1, 2)
P₀.₂₀(1,2)
```
"""
struct PInfection <: AbstractInfection
    t::  Float64
    infector:: Int
    infectee:: Int
    function PInfection(t, infector, infectee)
        noun = "PInfection($t, $infector, $infectee)"
        if infectee <= infector
            throw(DomainError(noun, "disordered marks"))
        elseif infector <= 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new(t, infector, infectee)
        end
    end
end


"""
    AbstractEnvironment

Represent an entire innovation of environment for a single step of algorithmic time.

Should always possess fields `n` (positive `Integer`) and
`chron` (`Vector{AbstractIncident}`), but displays `n`
together with
`infections`, `removals`, `cremovals` 
(sorted as **time-ordered** lists of corresponding incidents).
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
  AbstractInfection[P₀.₅₀(1,2), I₀.₇₀(1,2)],
  Removal[R₀.₁₀(2), R₀.₂₀(3)],
  CRemoval[C₀.₀₀(1), C₀.₀₅(2)])
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
        elseif any(i.infectee > n for i in infections)
            throw(ArgumentError("some infection targets too high in \n$noun"))
        else
            new(n, sort(infections), sort(removals), sort(cremovals))
        end
    end
end
