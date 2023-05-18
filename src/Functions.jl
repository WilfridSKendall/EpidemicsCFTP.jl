## Comparison of incidents by time
"""
    isless(inc1::AbstractIncident, inc2::AbstractIncident)::Bool

Implements comparison of two `AbstractIncident` quantities using time-order.

As indicated by the examples, logical comparison operators may be used.
However `inc1 == inc2` is _not_ a consequence of `inc1 ≤ inc2` and `inc1 ≥ inc2`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Removal(0.10, 3) < CRemoval(0.15, 2)
true
julia> Removal(0.10, 3) ≥ PInfection(0.15, 2, 7)
false
```
"""
function Base.isless(inc1::AbstractIncident, inc2::AbstractIncident)::Bool
    inc1.t < inc2.t
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
Implementation of `show` for `AbstractRemoval`, using subscripts and 2 decimal places for time `t`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Removal(0.10, 3)
R₀.₁₀(3)
julia> CRemoval(0.10, 3)
C₀.₁₀(3)
```
"""
function Base.show(io::IO, z::AbstractRemoval)
    id = string(typeof(z))[1]
    t = timespec(z.t)
    printfmt(io, "{1}{2}({3})", id, t, z.target)
end

"""
Implementation of `show` for `AbstractInfection` using subscripts and 2 decimal places for time `t`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Infection(0.10, 3, 4)
I₀.₁₀(3,4)
julia> PInfection(0.10, 3, 4)
P₀.₁₀(3,4)
```
"""
function Base.show(io::IO, z::AbstractInfection)
    id = string(typeof(z))[1]
    t = timespec(z.t)
    printfmt(io, "{1}{2}({3},{4})", id, t, z.infector, z.infectee)
end
