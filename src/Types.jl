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




## Compact printing
using Formatting

### Helper functions and format specifications for subscripts and superscripts
subs = split("₀₁₂₃₄₅₆₇₈₉._ ", "")
sups = split("⁰¹²³⁴⁵⁶⁷⁸⁹˙¯ ", "")
nums = split("0123456789.- ", "")
lows = Dict(nums[i]=>subs[i]  for i = 1:13)
upps = Dict(nums[i]=>sups[i]  for i = 1:13)

function lowers(x::String)::String
    join(lows[c] for c in split(x, ""))
end

function uppers(x::String)::String
    join(upps[c] for c in split(x, ""))
end

fspec = FormatSpec(".2f")

function timespec(t::Float64)::String
    lowers(fmt(fspec, t))
end

### Actual display functions
"""
Implementation of `show` for `Removal`, with `time` as subscript (2 decimal places).
"""
function Base.show(io::IO, z::Removal)
    id = string(typeof(z))[1]
    t = timespec(z.t)
    printfmt(io, "{1}{2}({3})", id, t, z.target)
end
