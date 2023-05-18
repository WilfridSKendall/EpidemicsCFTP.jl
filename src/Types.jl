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

Represents an abstract removal by a sub-type of `AbstractIncident`.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects field `target<:Integer`.

If the potential infection is to become realized 
then `target` must index a time-line which is infectious just before time `t`.

"""
abstract type AbstractRemoval <: AbstractIncident end

"""
    AbstractInfection

Represents an abstract infection by a sub-type of `AbstractIncident`.
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects fields `infector<:Integer` and `infectee<:Integer`,
such that `infector < infectee`.

If the potential infection is to become realized 
then `infector` must index a time-line which is infectious, 
and `infectee` must index the time-line of smallest
index which is susceptible, both measured just before time `t`.

In particular, if there is no timeline which is susceptible
just before time `t` then the infection will not be activated
whatever the value of `infectee`.

"""
abstract type AbstractInfection <: AbstractIncident end


## Various kinds of removal

"""
    Removal(t::Real, target::Integer)

Implements a potential removal by a sub-type of `AbstractRemoval`.  
The `target` field labels the timeline being considered as host for the removal incident: it must be a positive integer.  
The `Removal` is activated if the specified timeline is infectious just before time `t`.

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

Represent a conditioned removal by a sub-type of `AbstractRemoval`, similar to `Removal`.
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

Represent a potential infection by a sub-type of `AbstractInfection`,
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

Represent a perpetuated infection by a sub-type of `AbstractInfection`
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


