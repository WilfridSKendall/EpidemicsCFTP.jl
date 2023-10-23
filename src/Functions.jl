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

## Altering `CRemoval` timeline
"""
    alter(crem::CRemoval, timeline::Integer)::CRemoval

Produce a new `CRemoval`: same time `t` but changing
the mark `target` of `crem::CRemoval` to a positive `timeline`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> crem = CRemoval(0.15, 4)
𝒞₀.₁₅⁴

julia> alter(crem, 2)
𝒞₀.₁₅²

julia> crem
𝒞₀.₁₅⁴
```
"""
function alter(crem::CRemoval, new_timeline::Integer)::CRemoval
    if  0 < new_timeline
        CRemoval(crem.t, new_timeline)
    else
        throw(ArgumentError("cannot give $crem a non-positive new timeline $new_timeline"))
    end
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
function is_infectable(state::SIR, event::AbstractInfection)::Bool
    event.t >= state.t && event.target > state.r && event.infectee == state.i + state.r + 1
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
function is_removeable(state::SIR, event::AbstractRemoval)::Bool
    event.t >= state.t && event.target > state.r && event.target <= state.i + state.r
end


"""
    EpidemicsCFTP.update(state::SIR, event::AbstractIncident)::SIR

Applies incident to a given state and returns resulting incident.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), Removal(0.2, 4))
SIR₀.₂₀(1:1:4)
```
"""
function update(state::SIR, event::AbstractIncident)::SIR
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
    evolution(initial_state::SIR, innovation::Innovation; conditioned::Bool=false) ::Tuple{Vector{SIR},Vector{AbstractIncident}}

Evolves an S-I-R epidemic from an initial `SIR` state using
an `Innovation`. Returns
a list of `SIR` states and a history `Vector{AbstractIncident}` of realized incidents.
**NOTE:** the evolution starts at the time of the initial state! Earlier incidents are ignored.

If the keyword argument `conditioned` is set to its non-default value of `true`
then an error is raised when the function attempts to realize a `Removal`
or fails to realize a `CRemoval`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial_state = SIR(0.01, 1, 2, 3) ; population = 6 ;

julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[Removal(0.5, 4)], CRemoval[]) ;

julia> states, history = evolution(initial_state, innovation) ;

julia> states
SIR[SIR₀.₀₁(1:2:3),SIR₀.₅₀(1:1:4),SIR₀.₆₀(0:2:4)]

julia> history
AbstractIncident[ℛ₀.₅₀⁴,ℐ₀.₆₀⁵⁻⁶]

julia> evolution(initial_state, innovation, conditioned=true)
ERROR: [EmployedRemoval] The (conditioned) evolution misused Removal(0.5, 4)

julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[], [CRemoval(0.5, 4)]) ;

julia> states, history = evolution(initial_state, innovation) ;

julia> states
SIR[SIR₀.₀₁(1:2:3),SIR₀.₅₀(1:1:4),SIR₀.₆₀(0:2:4)]

julia> history
AbstractIncident[𝒞₀.₅₀⁴,ℐ₀.₆₀⁵⁻⁶]
 
julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[], [CRemoval(0.5, 1)]) ;

julia> evolution(initial_state, innovation, conditioned=true) ;
ERROR: [MissedCRemoval] The (conditioned) evolution misused CRemoval(0.5, 1)

julia> initial_state = SIR(0.55, 1, 2, 3) ;

julia> evolution(initial_state, innovation, conditioned=true)
(SIR[SIR(0.55, 1, 2, 3, 6), SIR(0.6, 0, 3, 3, 6)], AbstractIncident[Infection(0.6, 5, 6)])
```
"""
function evolution(initial_state::SIR, innovation::Innovation; conditioned::Bool=false) ::Tuple{Vector{SIR},Vector{AbstractIncident}}
    trajectory, history = SIR[initial_state], AbstractIncident[]
    chronology  = [x for x in innovation.chronology if x.t ≥ initial_state.t]
    if ! isempty(chronology)
        for event in chronology
            new_state = update(trajectory[end], event)
            if ! is_same_config(new_state, trajectory[end])
                if conditioned && isa(event, Removal)
                    throw(EmployedRemoval(event))
                end
                push!(trajectory, new_state)
                push!(history, event)
            elseif conditioned && isa(event, CRemoval)
                    throw(MissedCRemoval(event))
            end
        end
    end
    return trajectory, history
end

"""
    generate_innovation(iv::Innovation, duration::Real; α::Real=0.2, β::Real=0.1)

Generates a random innovation, borrowing some structure from its first argument.

# _Later work to be done:_
1. _The code and name for this function should be adapted to take 
account of the section on "Create New Samplers and Distributions"
from [`Distributions.jl`](https://juliastats.org/Distributions.jl/stable/extends/)._
2. _Conduct a simulation study (in a separate `quarto` notebook) to verify that 
the Poisson intensity rates used by this function are correct._
"""
function generate_innovation(iv::Innovation, duration::Real; α::Real=0.2, β::Real=0.1)
    n = iv.population
    removals = union([Removal[Removal(t, k) 
        for t in rand(Distributions.Uniform(0, duration), rand(Distributions.Poisson(β * duration)))] 
        for k in 1:n]...)
    infections = union(Vector{AbstractInfection}[[
                        Infection(t, rand(Distributions.DiscreteUniform(1, k-1)), k)
                    for t in rand(Distributions.Uniform(0, duration), 
                        rand(Distributions.Poisson((k-1) * (n - k + 1) * α * duration)))] 
                    for k in 2:n]...)
    if isempty(iv.cremovals)
        return Innovation(n, infections, removals)
    else
        cremovals = CRemoval[alter(x...) 
            for x in zip(iv.cremovals, 
                rand(Distributions.DiscreteUniform(1, n), length(iv.cremovals)))]
        return Innovation(n, infections, removals, cremovals)
    end
end

"""
    generate_innovation(n::Integer, duration::Real; α::Real=0.2, β::Real=0.1)

Generates a random innovation (with empty `cremoval` list), using first argument for population size.

_Later work to be done:_ see remarks for 
`generate_innovation(iv::Innovation, duration::Real; α::Real=0.2, β::Real=0.1)`.
"""
function generate_innovation(n::Integer, duration::Real; α::Real=0.2, β::Real=0.1)
    removals = union([Removal[Removal(t, k) 
        for t in rand(Distributions.Uniform(0, duration), rand(Distributions.Poisson(β * duration)))] 
        for k in 1:n]...)
    infections = union(Vector{AbstractInfection}[[
                        Infection(t, rand(Distributions.DiscreteUniform(1, k-1)), k)
                    for t in rand(Distributions.Uniform(0, duration), 
                        rand(Distributions.Poisson((k-1) * (n - k + 1) * α * duration)))] 
                    for k in 2:n]...)
    return Innovation(n, infections, removals)
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
    Base.show(io::IO, ::MIME"text/plain", z::AbstractRemoval)
    
Implementation of `show` for `AbstractRemoval`, using `MIME("text/plain")` as the
middle of three arguments and employing subscripts and 2 decimal places for time `t`,
and superscript for the `target` field.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Removal(0.10, 3)
ℛ₀.₁₀³
julia> CRemoval(0.10, 3)
𝒞₀.₁₀³
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractRemoval)
    t = timespec(z.t)
    printfmt(io, "{1}{2}{3}", z.kind, t, uppers(string(z.target)))
end

"""
    Base.show(io::IO, z::AbstractRemoval)

This applies when used with `print`, being the string produced
buy `repr`, and can be used 
as input to produce a copy.
## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> print(Removal(0.10, 3))
Removal(0.1, 3)
julia> print(CRemoval(0.10, 3))
CRemoval(0.1, 3)
```
"""
function Base.show(io::IO, z::AbstractRemoval)
    t = timespec(z.t)
    print(io, "$(typeof(z))($(z.t), $(z.target))")
end

"""
    Base.show(io::IO, ::MIME"text/plain", z::AbstractInfection)
    
Implementation of `show` for `AbstractInfection`, using `MIME("text/plain")` as the
middle of three arguments and employing subscripts and 2 decimal places for time `t`,
and superscripts for the `target` and `infectee` fields.
Note that a more general form (arising for example from use of `print`) can be used 
as input to produce a copy.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Infection(0.10, 3, 4)
ℐ₀.₁₀³⁻⁴
julia> PInfection(0.10, 3, 4)
𝒫₀.₁₀³⁻⁴
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractInfection)
    t = timespec(z.t)
    printfmt(io, "{1}{2}{3}⁻{4}", z.kind, t, uppers(string(z.target)), uppers(string(z.infectee)))
end

"""
    show(io::IO, z::AbstractInfection)

This applies when used with `print`, being the string produced
buy `repr`, and can be used 
as input to produce a copy.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> print(Infection(0.10, 3, 4))
Infection(0.1, 3, 4)
julia> print(PInfection(0.10, 3, 4))
PInfection(0.1, 3, 4)
```
"""
function Base.show(io::IO, z::AbstractInfection)
    t = timespec(z.t)
    print(io, "$(typeof(z))($(z.t), $(z.target), $(z.infectee))")
end

"""
    Base.show(io::IO, ::MIME"text/plain", z::Innovation)
    
Implementation of `show` for `Innovation` as three rows of lists of incidents
-- or two rows if no `CRemoval`s. We illustrate this second version here.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> population = 3
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] 
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.1, 2), Removal(0.2, 3)] 
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]

julia> Innovation(population, infections, removals, CRemoval[])
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
)
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::Innovation)
    println(io, "$(typeof(z))($(z.population),")
    print(io, rpad("infections:",12," "), sprint(show, MIME("text/plain"), z.infections))
    print(io, rpad("removals:",12," "), sprint(show, MIME("text/plain"), z.removals))
    isempty(z.cremovals) ? nothing : print(io, rpad("cremovals:",12," "),sprint(show, MIME("text/plain"), z.cremovals))
    print(io, ")")
end

"""
    Base.show(io::IO, z::Innovation)
    
## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> population = 3
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] 
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.1, 2), Removal(0.2, 3)]
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]

julia> print(Innovation(population, infections, removals, CRemoval[]))
Innovation(3,
  OperativeInfection[PInfection(0.5, 1, 2), Infection(0.7, 1, 2)],
  Removal[Removal(0.1, 2), Removal(0.2, 3)])
```
"""
function Base.show(io::IO, z::Innovation)
    if isempty(z.cremovals)
        printfmt(io, "{1}({2},\n  {3},\n  {4})",
                    typeof(z), z.population, z.infections, z.removals)
    else
        printfmt(io, "{1}({2},\n  {3},\n  {4},\n  {5})",
                    typeof(z), z.population, z.infections, z.removals, z.cremovals)
    end
end


"""
    Base.show(io::IO, ::MIME"text/plain", z::SIR)
    
Implementation of `show` for `SIR` using subscript and 2 decimal places for time.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> SIR(0.4, 1, 2, 3)
SIR₀.₄₀(1:2:3)
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::SIR)
    printfmt(io, "SIR{1}({2}:{3}:{4})", timespec(z.t), z.s, z.i, z.r)
end


"""
    Base.show(io::IO, ::MIME"text/plain", z::AbstractEvolution)
    
Implementation of `show` for `AbstractEvolution` as three rows of lists of incidents
-- or two rows if no `CRemoval`s -- together with further calculations. 
We illustrate both these versions here.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial    = SIR(0.0, 2,1,0)
SIR₀.₀₀(2:1:0)
julia> population = initial.n
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)]
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.1, 2), Removal(0.2, 3)]
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
julia> cremovals = [CRemoval(0.6, 2)]
CRemoval[𝒞₀.₆₀²]
julia> innovation = Innovation(population, infections, removals, CRemoval[])
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
)

julia> Evolution(initial, innovation) 
Evolution(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
chronology: AbstractIncident[ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₅₀(1:2:0)]
history:    AbstractIncident[𝒫₀.₅₀¹⁻²]
)

julia> innovation = Innovation(population, infections, removals, cremovals)
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₆₀²]
)

julia> Evolution(initial, innovation)
Evolution(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₆₀²]
chronology: AbstractIncident[ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,𝒞₀.₆₀²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₅₀(1:2:0),SIR₀.₆₀(1:1:1)]
history:    AbstractIncident[𝒫₀.₅₀¹⁻²,𝒞₀.₆₀²]
) 
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractEvolution) 
    println(io, "$(typeof(z))($(z.population),")
    print(io, rpad("infections:",12," "), sprint(show, MIME("text/plain"), z.infections))
    print(io, rpad("removals:",12," "), sprint(show, MIME("text/plain"), z.removals))
    isempty(z.cremovals) ? nothing : print(io, rpad("cremovals:",12," "), sprint(show, MIME("text/plain"), z.cremovals))
    print(io, rpad("chronology:",12," "), sprint(show, MIME("text/plain"), z.chronology))
    print(io, rpad("trajectory:",12," "), sprint(show, MIME("text/plain"), z.trajectory))
    print(io, rpad("history:",12," "), sprint(show, MIME("text/plain"), z.history))
    print(io, ")")
end

"""
    show(::IO, ::MIME"text/plain", ::Vector{T}; ::Int, ::String) where T <: AbstractTimedOccurrence

Implementation of `show` for vector of `AbstractTimedOccurrence` with line-breaking.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> infections = repeat([Infection(0.7,1,2), PInfection(0.5,1,2)], 6)
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,
    𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
```
"""
function Base.show(io::IO, ::MIME"text/plain", xv::Vector{T}; width::Int=75, tab::String=' '^4) where T <: AbstractTimedOccurrence
    if isempty(xv)
        println(io, "$(string(T))[]")
    else
        parts = [sprint(show, MIME("text/plain"), a) for a in xv]
        parts[1] = "$(string(T))[" * parts[1]
        parts[end] = parts[end]*"]"
        broken = []
        cumulative, clength, initial = [], 0, true
        for bit in parts
            clength = clength + length(bit)
            if clength > width
                addition = join(cumulative, ',') * ','
                push!(broken, initial ? addition : tab * addition)
                cumulative, clength, initial = [bit], length(bit), false
            else
                push!(cumulative, bit)
            end
        end
        if length(cumulative) > 0
            addition = join(cumulative, ',')
            push!(broken, initial ? addition :  tab * addition)
        end
        for section in broken
            println(io, section)
        end
    end
end



"""
    Base.show(io::IO, e::BadIncident)
    
Printing a `BadIncident` exception.
Sub-types are: `EmployedRemoval` and `MissedCRemoval`, raised respectively when a 
conditioned evolution uses a `Removal` which _is_ _not_ conditioned to appear in the trajectory,
or doesn't use a `CRemoval` which _is_ conditioned to appear in the trajectory.
See these types for doctests.
"""
function Base.show(io::IO, e::BadIncident)
    print(io, "[$(typeof(e))] The (conditioned) evolution misused $(e.incident)")
end
