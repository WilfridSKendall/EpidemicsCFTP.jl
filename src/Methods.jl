# # Comparison of incidents by time
# # -------------------------------
"""
    isearlier(inc1::AbstractTimedOccurrence, inc2::AbstractTimedOccurrence)::Bool

Implements comparison of two [`AbstractTimedOccurrence`](@ref) quantities using time-order.

We choose not to overload `isless`, because there isn't a total ordering here!

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

# # Altering `CRemoval` timeline
# # -------------------------------
"""
    alter(crem::CRemoval, timeline::Integer)::CRemoval

Produce a new [`CRemoval`](@ref): same time `t` but changing
the mark `target` of the [`CRemoval`](@ref) `rem`
to point to a positive `timeline` specified by the `Integer` argument.

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

# # Check if incident is activatable
# # -------------------------------
"""
    EpidemicsCFTP.is_activatable(state::SIR, inc::AbstractInfection)::Bool
    EpidemicsCFTP.is_activatable(state::SIR, inc::AbstractRemoval)::Bool

Tests whether an incident should be activated for a given state.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), Infection(0.1, 4, 6))
true
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), ExpungedInfection(0.1, 4, 6))
false
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), Infection(0.1, 4, 5))
false
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), Removal(0.1, 4))
true
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), KilledRemoval(0.1, 4))
false
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), Removal(0.1, 6))
false
```
"""
function is_activatable(state::SIR, z::AbstractInfection)::Bool
    z isa OperativeInfection && 
        z.t >= state.t && z.target > state.r && z.infectee == state.i + state.r + 1
end
function is_activatable(state::SIR, z::AbstractRemoval)::Bool
    z isa OperativeRemoval && 
        z.t >= state.t && z.target > state.r && z.target <= state.i + state.r
end

# # Activate an infection
# # -------------------------------
"""
    EpidemicsCFTP.infect(t::Real, state::SIR)::SIR

Change state of a `S-I-R` epidemic to activate an infection at time `t`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.infect(0.1, SIR(0.0, 1, 2, 3))
SIR₀.₁₀(0:3:3)
```
"""
function infect(t::Real, state::SIR)::SIR
    SIR(t, state.s - 1, state.i + 1, state.r)
end

# # Activate a removal
# # -------------------------------
"""
    EpidemicsCFTP.remove(t::Real, state::SIR)::SIR

Change state of a `S-I-R` epidemic to activate a removal at time `t`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.remove(0.1, SIR(0.0, 1, 2, 3))
SIR₀.₁₀(1:1:4)
```
"""
function remove(t::Real, state::SIR)::SIR
    SIR(t, state.s, state.i - 1, state.r + 1)
end

# # Update using an incident
# # -------------------------------
"""
    EpidemicsCFTP.update(state::SIR, z::AbstractIncident)::SIR

Applies [`AbstractIncident`](@ref)
to a given state and returns resulting state if it is activated (and hence operative).
Otherwise returns original state but with updated time `t`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), Removal(0.2, 4))
SIR₀.₂₀(1:1:4)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), KilledRemoval(0.2, 4))
SIR₀.₂₀(1:2:3)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), Infection(0.2, 4, 6))
SIR₀.₂₀(0:3:3)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), ExpungedInfection(0.2, 4, 6))
SIR₀.₂₀(1:2:3)
```
"""
function update(state::SIR, z::AbstractIncident)::SIR
    if state.t > z.t
        return state
    elseif z isa OperativeRemoval   && is_activatable(state, z)
        return remove(z.t, state)
    elseif z isa OperativeInfection && is_activatable(state, z)
        return infect(z.t, state)
    else
        return SIR(z.t, state.s, state.i, state.r)
    end
end

# # Updating in reverse time
# # -------------------------------
"""
    function antecedent(::SIR, ::AbstractInfection)::SIR
    function antecedent(::SIR, ::AbstractRemoval)::SIR

Computes state before stated incident (no check made as to whether this is possible!).
"""
function antecedent(state::SIR, event::AbstractInfection)::SIR
    SIR(event.t, state.s + 1, state.i - 1, state.r)
end
function antecedent(state::SIR, event::AbstractRemoval)::SIR
    SIR(event.t, state.s, state.i + 1, state.r - 1)
end

"""
    reverse_update(::SIR, ::AbstractIncident)::SIR

Performs reverse update if this is possible
"""
function reverse_update(state::SIR, event::AbstractIncident)::SIR
    if event.t > state.t
        return state
    end
    result = SIR(event.t, state.s, state.i, state.r)
    if (event isa AbstractRemoval && state.r > 0) || 
            (event isa AbstractInfection && state.i > 0)
        prior = antecedent(state, event)
        if is_activatable(prior, event)
            result = prior
        end
    end
    return result
end


# # Test if two configurations agree (except for time!)
# # -------------------------------
"""
    EpidemicsCFTP.is_same_config(state1::SIR, state2::SIR)::Bool

Checks if the two [`SIR`](@ref) states have the same values for `s`, `i`, `r` fields
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

# # Evolve an epidemic
# # -------------------------------
"""
    evolution(::SIR, ::Vector{T}; conditioned::Bool=false)          
        ::Tuple{Vector{SIR},Vector{AbstractIncident}} where T <: AbstractIncident
    evolution(::SIR, ::Innovation; conditioned::Bool=false)          
        ::Tuple{Vector{SIR},Vector{AbstractIncident}}

Evolves a `S-I-R` epidemic from an initial [`SIR`](@ref) state using
an [`Innovation`](@ref). Returns
a list of `SIR` states and a history `Vector{AbstractIncident}` of realized incidents.
**NOTE:** the evolution starts at the time of the initial state! Earlier incidents are ignored.

If the keyword argument `conditioned` is set to its non-default value of `true`
then an error is raised when the function attempts to realize a [`Removal`](@ref)
or fails to realize a [`CRemoval`](@ref).

Note that this method is employed in the construction of [`Evolution`](@ref)
and (with the `conditioned` flag set to `true`) [`CEvolution`](@ref) objects.

## Example
I: Basic use, unconditioned
```jldoctest evolution; setup = :(using EpidemicsCFTP)
julia> initial_state = SIR(0.01, 1, 2, 3) ; population = 6 ;

julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[Removal(0.5, 4)], CRemoval[]) ;

julia> states, history = evolution(initial_state, innovation) ;

julia> states
SIR[SIR₀.₀₁(1:2:3),SIR₀.₅₀(1:1:4),SIR₀.₆₀(0:2:4)]

julia> history
AbstractIncident[ℛ₀.₅₀⁴,ℐ₀.₆₀⁵⁻⁶]
```

II: Basic use, conditioned (A)
```jldoctest evolution
julia> evolution(initial_state, innovation, conditioned=true)
ERROR: [EmployedRemoval] The (conditioned) evolution misused Removal(0.5, 4)

julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[], [CRemoval(0.5, 4)]) ;

julia> states, history = evolution(initial_state, innovation) ;

julia> states
SIR[SIR₀.₀₁(1:2:3),SIR₀.₅₀(1:1:4),SIR₀.₆₀(0:2:4)]

julia> history
AbstractIncident[𝒞₀.₅₀⁴,ℐ₀.₆₀⁵⁻⁶]
```

III: Basic use, conditioned (B)
```jldoctest evolution
julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[], [CRemoval(0.5, 1)]) ;

julia> evolution(initial_state, innovation, conditioned=true) ;
ERROR: [MissedCRemoval] The (conditioned) evolution misused CRemoval(0.5, 1)

julia> initial_state = SIR(0.55, 1, 2, 3) ;

julia> answer = evolution(initial_state, innovation, conditioned=true) ;

julia> answer[1]
SIR[SIR₀.₅₅(1:2:3),SIR₀.₆₀(0:3:3)]
julia> answer[2]
AbstractIncident[ℐ₀.₆₀⁵⁻⁶]
```
"""
function evolution(initial_state::SIR, innovation::Innovation; conditioned::Bool=false) ::Tuple{Vector{SIR},Vector{AbstractIncident}}
    return evolution(initial_state, innovation.chronology; conditioned=conditioned)
end

function evolution(initial_state::SIR, chronology::Vector{T}; conditioned::Bool=false) ::Tuple{Vector{SIR},Vector{AbstractIncident}} where T <: AbstractIncident
    trajectory, history = SIR[initial_state], AbstractIncident[]
    chron  = [x for x ∈ chronology if x.t ≥ initial_state.t]
    if ! isempty(chron)
        for z ∈ chron
            new_state = update(trajectory[end], z)
            if ! is_same_config(new_state, trajectory[end])
                if conditioned && z isa Removal
                    throw(EmployedRemoval(z))
                end
                push!(trajectory, new_state)
                push!(history, z)
            elseif conditioned && z isa CRemoval
                    throw(MissedCRemoval(z))
            end
        end
    end
    return trajectory, history
end

"""
    evolution_history(::SIR, ::Vector{T}; conditioned::Bool=false)          
        ::Vector{AbstractIncident} where T <: AbstractIncident
    evolution_history(::SIR, ::Innovation; conditioned::Bool=false)          
        ::Vector{AbstractIncident}

Evolves a `S-I-R` epidemic from an initial [`SIR`](@ref) state using
an [`Innovation`](@ref). Returns
only the _history_ `Vector{AbstractIncident}` of realized incidents.
**NOTE:** the evolution starts at the time of the initial state! Earlier incidents are ignored.

If the keyword argument `conditioned` is set to its non-default value of `true`
then an error is raised when the function attempts to realize a [`Removal`](@ref)
or fails to realize a [`CRemoval`](@ref).

Note that this method may later be employed in the construction of [`Evolution`](@ref)
and (with the `conditioned` flag set to `true`) [`CEvolution`](@ref) objects.

## Example
I: Basic use, unconditioned
```jldoctest evolution; setup = :(using EpidemicsCFTP)
julia> initial_state = SIR(0.01, 1, 2, 3) ; population = 6 ;

julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[Removal(0.5, 4)], CRemoval[]) ;

julia> evolution_history(initial_state, innovation)
AbstractIncident[ℛ₀.₅₀⁴,ℐ₀.₆₀⁵⁻⁶]
```

II: Basic use, conditioned (A)
```jldoctest evolution
julia> evolution_history(initial_state, innovation, conditioned=true)
ERROR: [EmployedRemoval] The (conditioned) evolution misused Removal(0.5, 4)

julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[], [CRemoval(0.5, 4)]) ;

julia> evolution_history(initial_state, innovation)
AbstractIncident[𝒞₀.₅₀⁴,ℐ₀.₆₀⁵⁻⁶]
```

III: Basic use, conditioned (B)
```jldoctest evolution
julia> innovation = Innovation(population, [Infection(0.6, 5, 6)], Removal[], [CRemoval(0.5, 1)]) ;

julia> evolution_history(initial_state, innovation, conditioned=true) ;
ERROR: [MissedCRemoval] The (conditioned) evolution misused CRemoval(0.5, 1)

julia> initial_state = SIR(0.55, 1, 2, 3) ;

julia> evolution_history(initial_state, innovation, conditioned=true)
AbstractIncident[ℐ₀.₆₀⁵⁻⁶]
```
"""
function evolution_history(initial_state::SIR, innovation::Innovation; conditioned::Bool=false) ::Vector{AbstractIncident}
    return evolution_history(initial_state, innovation.chronology; conditioned=conditioned)
end

function evolution_history(initial_state::SIR, chronology::Vector{T}; conditioned::Bool=false) ::Vector{AbstractIncident} where T <: AbstractIncident
    
    current_state, history = initial_state, AbstractIncident[]
    for z ∈ [x for x ∈ chronology if x.t ≥ initial_state.t]
        new_state = update(current_state, z)
        if ! is_same_config(new_state, current_state)
            if conditioned && z isa Removal
                throw(EmployedRemoval(z))
            end
            current_state = new_state
            push!(history, z)
        elseif conditioned && z isa CRemoval
                throw(MissedCRemoval(z))
        end
    end
    
    return history
end

# # Computing the last feasible epidemic trajectory
# # ---------------------------------
"""
    last_feasible_evolution(::Real, ::AbstractEvolution, ::Innovation; ::Bool=false)
            ::Vector{AbstractIncident}

Computes the last feasible epidemic trajectory.
"""
function last_feasible_evolution(duration::Real, ev::AbstractEvolution, iv::Innovation;
    conditioned::Bool=false) ::Vector{AbstractIncident}                       # <1>
    chronology = sort(iv.infections ∪ ev.history, lt=isearlier)               # <2>
    current_state = SIR(duration, 
        ev.trajectory[end].s, ev.trajectory[end].i, ev.trajectory[end].r)

    reverse_history = AbstractIncident[]
    reverse_chronology  = reverse([x for x ∈ chronology if x.t <= current_state.t])

    if ! isempty(reverse_chronology)
        for event ∈ reverse_chronology
            prior_state = EpidemicsCFTP.reverse_update(current_state, event)
            if ! EpidemicsCFTP.is_same_config(prior_state, current_state)
                if conditioned && event isa Removal
                    throw(EmployedRemoval(event))
                end
                current_state = prior_state
                push!(reverse_history, event)
            elseif conditioned && event isa CRemoval
                throw(MissedCRemoval(event))
            end
        end
    end

    return Base.reverse(reverse_history)
end 
# ## 1. Allow for non-zero starting time?
# ## 2. Truncate `chronology` to run only up to `duration`?
    
# # Compute infectious periods
# # -------------------------------
"""
    EpidemicsCFTP.periods(::Vector{SIR}, ::Vector{AbstractIncident})
        ::Tuple{Vector{Real}, Vector{Real}}
    
Returns starts and ends of infectious periods.

**NOTE:** _maybe later introduce start end and time options!_

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> trajectory = [SIR(0.01, 1,2,3), SIR(0.5, 1,1,4), SIR(0.6, 0,2,4)]
SIR[SIR₀.₀₁(1:2:3),SIR₀.₅₀(1:1:4),SIR₀.₆₀(0:2:4)]
julia> history = AbstractIncident[Removal(0.5, 4), Infection(0.6, 5, 6)]
AbstractIncident[ℛ₀.₅₀⁴,ℐ₀.₆₀⁵⁻⁶]

julia> births, deaths = EpidemicsCFTP.periods(trajectory, history)
(Real[0.0, 0.0, 0.0, 0.0, 0.0, 0.6], Real[0.0, 0.0, 0.0, 0.5, Inf, Inf])
julia> println(births)
Real[0.0, 0.0, 0.0, 0.0, 0.0, 0.6]
julia> println(deaths)
Real[0.0, 0.0, 0.0, 0.5, Inf, Inf]
```
"""
function periods(trajectory::Vector{SIR},
                 history::Vector{AbstractIncident})::Tuple{Vector{Real}, Vector{Real}}
    start, finis = trajectory[1], trajectory[end]
    
    # Compute birth times
    births = sort([z.t for z ∈ history if z isa OperativeInfection])
    prepend!(births, repeat([0.0], start.i + start.r))
    append!(births, repeat([Inf], finis.s)) # Or replace `Inf` by `duration`
    
    # Compute death times
    deaths = sort([z.t for z ∈ history if z isa OperativeRemoval])
    prepend!(deaths, repeat([0.0], start.r))
    append!(deaths, repeat([Inf], finis.i + finis.s)) # Or replace `Inf` by `duration`
    
    # Check same number of births as deaths
    if length(births) != length(deaths)
        error("birth and death numbers ($(length(births)), $(length(deaths))) disagree")
    end

    return births, deaths
end

# # Kill irrelevant infections and removals
# # -------------------------------
"""
    kill_irrelevant_infections(::Evolution, ::Innovation)::Vector{AbstractInfection}

Examines [`AbstractInfection`](@ref)s from [`Innovation`](@ref) and determines which
are irrelevant (occurring in removal zone for [`Evolution`](@ref)). converting these
to [`KilledRemoval`](@ref)s.
"""
function kill_irrelevant_infections(ev::Evolution, iv::Innovation)::Vector{AbstractInfection}
    [ z.t ≤ ev.finis_times[z.target] ? z : KilledInfection(z) for z ∈ iv.infections ]
end ;

"""
    kill_irrelevant_removals(::Evolution, ::Innovation)::Vector{AbstractRemoval}

Examines [`AbstractRemoval`](@ref)s from [`Innovation`](@ref) and determines which
are irrelevant (occurring in removal zone for [`Evolution`](@ref)). converting these
to [`KilledInfection`](@ref)s.
"""
function kill_irrelevant_removals(ev::Evolution, iv::Innovation)::Vector{AbstractRemoval}
    [ z.t ≤ ev.finis_times[z.target] ? z : KilledRemoval(z) for z ∈ iv.removals ]
end ;

# # Identify relevant infections
# # -------------------------------
"""
    relevant_infections(::Evolution, ::Innovation)::Vector{AbstractInfection}

Examines [`AbstractInfection`](@ref)s from [`Innovation`](@ref) and returns
those which are relevant to construction of the "last feasible epidemic".
"""
function relevant_infections(ev::Evolution, iv::Innovation)::Vector{AbstractInfection}
    unkilled = [z for z ∈ kill_irrelevant_infections(ev, iv) if z isa OperativeInfection]
    relevant_inf = [z for z ∈ ev.history if typeof(z) <: AbstractInfection]
    rsup, running_supremum_list = 0, CRemoval[]
    for z ∈ sort(ev.cremovals ∪ unkilled, lt=isearlier)
        if (typeof(z) == CRemoval) && (z.target > rsup)
            push!(running_supremum_list, z)
            rsup = z.target
        elseif typeof(z) <: AbstractInfection &&
                ev.start_times[z.target] ≤ z.t < ev.finis_times[z.target] && 
                z.infectee > rsup
            push!(relevant_inf, z)
        end
    end
    return sort(relevant_inf, lt=isearlier)
end 
    
# # Extract and classify inactive removals
# # -------------------------------
"""
    inactive_removals(::AbstractEvolution, ::Innovation)::Vector{AbstractRemoval}
    
This function extracts and classifies the inactive [`AbstractRemoval`](@ref)s from an [`Evolution`](@ref).
Those which lie in the removals zone are converted to [`KilledRemoval`](@ref)s.

### Possible improvement
Modify `relevant_infections` to exclude potential infections that
rise above current epidemic trajectory? Not doing it now, because
I don't think it affects the programming, but it may help clarity
when moving on to deal with the (so-called) "no fly zone"!

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial_state = SIR(0.55, 1, 2, 3) ; n = 6 ;

julia> innovation = Innovation(n, [Infection(0.6, 5, 6)], Removal[Removal(0.5, 4)], CRemoval[]) ;

julia> ev = Evolution(initial_state, innovation) ;

julia> rem = Removal[Removal(0.56, 1), Removal(0.57, 2), Removal(0.58, 6)]
Removal[ℛ₀.₅₆¹,ℛ₀.₅₇²,ℛ₀.₅₈⁶]
julia> innov2 = Innovation(n, [Infection(0.6, 5, 6)], rem, [CRemoval(0.5, 1)]) ;

julia> EpidemicsCFTP.inactive_removals(ev, innov2)
AbstractRemoval[𝒦₀.₅₆¹,𝒦₀.₅₇²,ℛ₀.₅₈⁶]
```
"""
function inactive_removals(ev::AbstractEvolution, innov::Innovation)::Vector{AbstractRemoval}
    not_killed = [z for z ∈ innov.removals if z.t < ev.start_times[z.target]]
    killed     = [KilledRemoval(z) for z ∈ innov.removals if ev.finis_times[z.target] ≤ z.t]
    return sort(not_killed ∪ killed, lt=isearlier)
end    

# # Accept/reject procedure
# # -------------------------------

"""
    accept_reject(::CRemoval, ::CRemoval, ::Vector{Real}, ::Vector{Real})::CRemoval

Performs an accept/reject procedure: accept the [`CRemoval`](@ref) `proposed_cremoval` only if it would actually
be activated based on period `start_time`s and `finis_time`s
generated by [`EpidemicsCFTP.periods`](@ref): otherwise retain the [`CRemoval`](@ref) `old_cremoval`.
"""
function accept_reject(old_cremoval::CRemoval, proposed_cremoval::CRemoval,
                       start_time::Vector{Real}, finis_time::Vector{Real})::CRemoval
    t, k = proposed_cremoval.t, proposed_cremoval.target
    return start_time[k] ≤ t ≤ finis_time[k] ? proposed_cremoval : old_cremoval
end

"""
    resulting_cremovals(::AbstractEvolution, ::Innovation)::Vector{CRemoval}

Uses [`EpidemicsCFTP.accept_reject`](@ref) to determine re-sampled set of [`CRemoval`](@ref)s
based on period `start_times` and `finis_times`
generated by [`EpidemicsCFTP.periods`](@ref).
"""
function resulting_cremovals(ev::AbstractEvolution, iv::Innovation)::Vector{CRemoval}
    [accept_reject(oldcr, propcr, ev.start_times, ev.finis_times) 
        for (oldcr, propcr) ∈ zip(ev.cremovals, iv.cremovals)]
end
    
# # Generate an innovation
# # -------------------------------
"""
    generate_innovation(iv::Innovation, duration::Real; α::Real=0.2, β::Real=0.1)

Generates a random [`Innovation`](@ref), borrowing some structure from its first argument.

# # _Later work to be done:_

1. The code and name for this function should be adapted to take 
account of the section on "Create New Samplers and Distributions"
from [`Distributions.jl`](https://juliastats.org/Distributions.jl/stable/extends/).

2. Conduct a simulation study (in a separate `quarto` notebook) to verify that the Poisson intensity rates used by this function are correct.

"""
function generate_innovation(iv::Innovation, duration::Real; α::Real=0.2, β::Real=0.1)
    n = iv.population
    removals = ∪([AbstractRemoval[Removal(t, k) 
        for t ∈ rand(Distributions.Uniform(0, duration), rand(Distributions.Poisson(β * duration)))] 
        for k ∈ 1:n]...)
    infections = ∪(Vector{AbstractInfection}[[
                        Infection(t, rand(Distributions.DiscreteUniform(1, k-1)), k)
                    for t ∈ rand(Distributions.Uniform(0, duration), 
                        rand(Distributions.Poisson((k-1) * (n - k + 1) * α * duration)))] 
                    for k ∈ 2:n]...)
    if isempty(iv.cremovals)
        return Innovation(n, infections, removals)
    else
        cremovals = CRemoval[alter(x...) 
            for x ∈ zip(iv.cremovals, 
                rand(Distributions.DiscreteUniform(1, n), length(iv.cremovals)))]
        return Innovation(n, infections, removals, cremovals)
    end
end

"""
    generate_innovation(n::Integer, duration::Real; α::Real=0.2, β::Real=0.1)

Generates a random [`Innovation`](@ref) (with empty `cremoval` list), using first argument for population size.
"""
function generate_innovation(n::Integer, duration::Real; α::Real=0.2, β::Real=0.1)
    removals = ∪([AbstractRemoval[Removal(t, k) 
        for t ∈ rand(Distributions.Uniform(0, duration), rand(Distributions.Poisson(β * duration)))] 
        for k ∈ 1:n]...)
    infections = ∪(Vector{AbstractInfection}[[
                        Infection(t, rand(Distributions.DiscreteUniform(1, k-1)), k)
                    for t ∈ rand(Distributions.Uniform(0, duration), 
                        rand(Distributions.Poisson((k-1) * (n - k + 1) * α * duration)))] 
                    for k ∈ 2:n]...)
    return Innovation(n, infections, removals)
end
