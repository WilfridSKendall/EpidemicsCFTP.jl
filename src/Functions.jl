## Comparison of incidents by time

"""
    isearlier(inc1::AbstractTimedOccurrence, inc2::AbstractTimedOccurrence)::Bool

Implements comparison of two `AbstractTimedOccurrence` quantities using time-order.

We don't use `isless`, because we don't have a total ordering here!

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> isearlier(Removal(0.10, 3), CRemoval(0.15, 2))
true
julia> isearlier(PInfection(0.15, 2, 7), Removal(0.10, 3))
false
```
"""
function isearlier(inc1::AbstractTimedOccurrence, inc2::AbstractTimedOccurrence)::Bool
  inc1.t < inc2.t
end

## Produce a time-ordered list of incidents from an `AbstractEnvironment`.

"""
    chronology(env::AbstractEnvironment)::Vector{AbstractIncident}
    
Returns  time-ordered list of incidents from an `AbstractEnvironment`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
n = 3 ;
infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;
removals   = [Removal(0.1, 2), Removal(0.2, 3)] ;
cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 2)] ;
chronology(Innovation(n, infections, removals, cremovals))

# output
6-element Vector{AbstractIncident}:
 𝒞₀.₀₀¹
 𝒞₀.₀₅²
 ℛ₀.₁₀²
 ℛ₀.₂₀³
 𝒫₀.₅₀¹⁻²
 ℐ₀.₇₀¹⁻²
```
"""
function chronology(env::AbstractEnvironment)::Vector{AbstractIncident}
    chron = Iterators.flatten([env.infections, env.removals, env.cremovals]) ;
    [inc::AbstractIncident for inc in sort(collect(chron), lt=isearlier)]
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
ℛ₀.₁₀³
julia> CRemoval(0.10, 3)
𝒞₀.₁₀³
```
"""
function Base.show(io::IO, z::AbstractRemoval)
    t = timespec(z.t)
    printfmt(io, "{1}{2}{3}", z.kind, t, uppers(string(z.target)))
end

"""
Implementation of `show` for `AbstractInfection` using subscripts and 2 decimal places for time `t`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Infection(0.10, 3, 4)
ℐ₀.₁₀³⁻⁴
julia> PInfection(0.10, 3, 4)
𝒫₀.₁₀³⁻⁴
```
"""
function Base.show(io::IO, z::AbstractInfection)
    t = timespec(z.t)
    printfmt(io, "{1}{2}{3}⁻{4}", z.kind, t, uppers(string(z.infector)), uppers(string(z.infectee)))
end

"""
Implementation of `show` for `Innovation` as three rows of lists of incidents
-- or two rows if no `CRemoval`s. We illustrate this second version here.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
n = 3 ;
infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;
removals   = [Removal(0.1, 2), Removal(0.2, 3)] ;
Innovation(n, infections, removals, CRemoval[])

# output
Innovation(3,
  AbstractInfection[𝒫₀.₅₀¹⁻², ℐ₀.₇₀¹⁻²],
  Removal[ℛ₀.₁₀², ℛ₀.₂₀³])
```
"""
function Base.show(io::IO, z::Innovation)
    if isempty(z.cremovals)
        printfmt(io, "{1}({2},\n  {3},\n  {4})",
                    typeof(z), z.n, z.infections, z.removals)
    else
        printfmt(io, "{1}({2},\n  {3},\n  {4},\n  {5})",
                    typeof(z), z.n, z.infections, z.removals, z.cremovals)
    end
end

"""
Implementation of `show` for `SIR` using subscript and 2 decimal places for time.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
SIR(0.4, 1, 2, 3)

# output
SIR₀.₄₀(1:2:3)
```
"""
function Base.show(io::IO, z::SIR)
    printfmt(io, "SIR{1}({2}:{3}:{4})",
                 timespec(z.t), z.s, z.i, z.r)
end


"""
Implementation of `show` for `SIR` using subscript and 2 decimal places for time.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
SIR(0.4, 1, 2, 3)

# output
SIR₀.₄₀(1:2:3)
```
"""
function Base.show(io::IO, z::SIR)
    printfmt(io, "SIR{1}({2}:{3}:{4})",
                 timespec(z.t), z.s, z.i, z.r)
end
