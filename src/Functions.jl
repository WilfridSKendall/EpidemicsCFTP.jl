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

## Re-sampling `CRemoval` mark
"""
    resample(crem::CRemoval, population::Integer)::CRemoval

Produce a new `CRemoval`: same time `t` but re-sampling
the mark `target` of `crem::CRemoval` from the range `1:population`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> using Random

julia> Random.seed!(1) ;

julia> crem = CRemoval(0.15, 4)
𝒞₀.₁₅⁴

julia> resample(crem, 20)
𝒞₀.₁₅²

julia> crem
𝒞₀.₁₅⁴
```
"""
function resample(crem::CRemoval, population::Integer)::CRemoval
    CRemoval(crem.t, rand(1:population))
end

## Converting `Infection` to `PInfection`
"""
    perpetuate(pinf::Infection)::PInfection

Produce a new `PInfection` from an `Infection` using the same marks.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> infection_incident = Infection(0.04, 1, 4)
ℐ₀.₀₄¹⁻⁴
julia> perpetuate(infection_incident)
𝒫₀.₀₄¹⁻⁴
```
"""
function perpetuate(infection_incident::Infection)::PInfection
    PInfection(infection_incident.t, infection_incident.target, infection_incident.infectee)
end


"""
    EpidemicsCFTP.infect(t::Real, state::SIR)::SIR

Change state of an S-I-R epidemic to implement an infection at time `t`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.infect(0.1, SIR(0.0, 1, 2, 3))
SIR₀.₁₀(0:3:3)
```
"""
function infect(t::Real, state::SIR)::SIR
    SIR(t, state.s - 1, state.i + 1, state.r)
end


"""
    EpidemicsCFTP.is_infectable(state::SIR, inc::AbstractInfection)::Bool

Tests whether an infection should be implemented for a given state.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.is_infectable(SIR(0.0, 1, 2, 3), Infection(0.1, 4, 6))
true
julia> EpidemicsCFTP.is_infectable(SIR(0.0, 1, 2, 3), Infection(0.1, 4, 5))
false
```
"""
function is_infectable(state::SIR, inc::AbstractInfection)::Bool
    inc.t >= state.t && inc.target > state.r && inc.infectee == state.i + state.r + 1
end

"""
    EpidemicsCFTP.remove(t::Real, state::SIR)::SIR

Change state of an S-I-R epidemic to implement a removal at time `t`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.remove(0.1, SIR(0.0, 1, 2, 3))
SIR₀.₁₀(1:1:4)
```
"""
function remove(t::Real, state::SIR)::SIR
    SIR(t, state.s, state.i - 1, state.r + 1)
end


"""
    EpidemicsCFTP.is_removeable(state::SIR, event::AbstractRemoval)::Bool

Tests whether a removal should be implemented for a given state.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.is_removeable(SIR(0.0, 1, 2, 3), Removal(0.1, 4))
true
julia> EpidemicsCFTP.is_removeable(SIR(0.0, 1, 2, 3), Removal(0.1, 6))
false
```
"""
function is_removeable(state::SIR, inc::AbstractRemoval)::Bool
    inc.t >= state.t && inc.target > state.r && inc.target <= state.i + state.r
end


"""
    EpidemicsCFTP.update(state::SIR, event::Union{Removal, CRemoval, Infection, PInfection})::SIR

Applies incident to a given state and returns resulting incident.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), Removal(0.2, 4))
SIR₀.₂₀(1:1:4)
```
"""
function update(state::SIR, event::Union{Removal, CRemoval, Infection, PInfection})::SIR
    inc = typeof(event)
    if state.t > event.t
        return state
    elseif inc <: AbstractRemoval    && is_removeable(state, event)
        return remove(event.t, state)
    elseif inc <: AbstractInfection  && is_infectable(state, event)
        return infect(event.t, state)
    else
        return SIR(event.t, state.s, state.i, state.r)
    end
end

"""
    EpidemicsCFTP.is_same_config(state1::SIR, state2::SIR)::Bool

Checks if the two states have the same values for `s`, `i`, `r` fields
(but not `t` field).

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.is_same_config(SIR(0.1, 1, 2, 3), SIR(0.9, 1, 2, 3))
true
```

"""
function is_same_config(state1::SIR, state2::SIR)::Bool
    state1.s == state2.s && state1.i == state2.i && state1.r == state2.r
    end


"""
    evolution_recurse!(states::Vector{SIR}, t1::Real, history::Vector{AbstractIncident},
                        chron::Vector{AbstractIncident}; conditioned::Bool=false) ::Tuple{Vector{SIR},Vector{AbstractIncident}}

Evolves an S-I-R epidemic recursively from an initial pair of

1. a time-ordered list `states` of `SIR` states and 
2. and a `history` `Vector{AbstractIncident}`

to an updated list of `SIR` states running up to
time `t1`  and an updated history `Vector{AbstractIncident}`,
using a time-ordered stream `chron`
which is a `Vector{AbstractInfection}`.

If the keyword argument `conditioned` is set to its non-default value of `true`
then an error is raised whenever the function attempts to activate a `Removal`
(as opposed to a `CRemoval`).

**IMPORTANT:** Note that this function changes the contents
of `states`, `history` and `chron`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> states = SIR[SIR(0.01, 1, 2, 3)] ; t1 = 1.0 ;

julia> chron = AbstractIncident[Removal(0.5, 4), Infection(0.6, 5, 6)] ;

julia> states, history = evolution_recurse!(states, AbstractIncident[], t1, chron) ;

julia> states
3-element Vector{SIR}:
 SIR₀.₀₁(1:2:3)
 SIR₀.₅₀(1:1:4)
 SIR₀.₆₀(0:2:4)

julia> history
2-element Vector{AbstractIncident}:
 ℛ₀.₅₀⁴
 ℐ₀.₆₀⁵⁻⁶

julia> states = SIR[SIR(0.01, 1, 2, 3)] ; t1 = 1.0 ;

julia> chron = AbstractIncident[Removal(0.5, 4), Infection(0.6, 5, 6)] ;

julia> states, history = evolution_recurse!(states, AbstractIncident[], t1, chron, conditioned=true) ;
ERROR: evolution_recurse, with conditioned=true, tries to activate (unconditioned) removal ℛ₀.₅₀⁴

julia> states = SIR[SIR(0.01, 1, 2, 3)] ; t1 = 1.0 ;

julia> chron = AbstractIncident[CRemoval(0.5, 4), Infection(0.6, 5, 6)] ;

julia> states, history = evolution_recurse!(states, AbstractIncident[], t1, chron, conditioned=true) ;

julia> states
3-element Vector{SIR}:
 SIR₀.₀₁(1:2:3)
 SIR₀.₅₀(1:1:4)
 SIR₀.₆₀(0:2:4)

julia> history
2-element Vector{AbstractIncident}:
 𝒞₀.₅₀⁴
 ℐ₀.₆₀⁵⁻⁶
```
"""
function evolution_recurse!(states::Vector{SIR}, history::Vector{AbstractIncident}, t1::Real,
                    chron::Vector{AbstractIncident}; conditioned::Bool=false) ::Tuple{Vector{SIR},Vector{AbstractIncident}}
    if isempty(chron)
        return states, history
    else
        event = popfirst!(chron)
        if event.t <= t1
            new_state = update(states[end], event)
            if ! is_same_config(new_state, states[end])
                if conditioned && isa(event, Removal)
                    error("evolution_recurse, with conditioned=$conditioned, tries to activate (unconditioned) removal $(event)")
                end
                push!(states, new_state)
                push!(history, event)
            end
        end
        return evolution_recurse!(states, history, t1, chron, conditioned=conditioned)
    end
end


## Compact printing

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
Implementation of `show` for `AbstractMarker`, using subscripts and 2 decimal places for time `t`. 

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> InitialSusceptible(0.10, 3)
↦𝒮₀.₁₀³
julia> InitialInfected(0.10, 3)
↦ℐ₀.₁₀³
julia> InitialRemoved(0.10, 3)
↦ℛ₀.₁₀³
julia> MarkerInfectionA(0.10, 3)
⮥ℐ₀.₁₀³
julia> MarkerRemovalA(0.10, 3)
⮥ℛ₀.₁₀³
julia> MarkerInfectionB(0.10, 3)
⮣ℐ₀.₁₀³
julia> MarkerRemovalB(0.10, 3)
⮣ℛ₀.₁₀³
julia> ContinuingSusceptible(0.10, 3)
↠𝒮₀.₁₀³
julia> ContinuingInfected(0.10, 3)
↠ℐ₀.₁₀³
julia> ContinuingRemoved(0.10, 3)
↠ℛ₀.₁₀³
```
"""
function Base.show(io::IO, z::AbstractMarker)
    t = timespec(z.t)
    printfmt(io, "{1}{2}{3}", z.kind, t, uppers(string(z.target)))
end

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
    printfmt(io, "{1}{2}{3}⁻{4}", z.kind, t, uppers(string(z.target)), uppers(string(z.infectee)))
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

