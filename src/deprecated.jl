# deprecated.jl contains older functions no longer used!
# This file is under version control but no longer compiled.

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

**NOTE:** deprecated in favour of non-recursinve, non-destructive `evolution`.

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
