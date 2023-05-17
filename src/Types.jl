## Types for various incidents.

"""
    AbstractIncident

Represents an abstract incident (infection or removal) at a time specified by a `Real` number `t`.  
Expects field `t<:Real` (will be used by function `isless` to time-order lists of `AbstractIncident` entities).
"""
abstract type AbstractIncident end

## AbstractIncidents representing removals
"""
    AbstractRemoval

Represents an abstract removal by a sub-type of `AbstractIncident`.  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects field `target<:Integer`.
"""
abstract type AbstractRemoval <: AbstractIncident end

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



