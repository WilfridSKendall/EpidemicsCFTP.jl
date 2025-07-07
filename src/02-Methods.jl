# Helpful operators
# -----------------
# The following simple notation enables concise expression of _CFTP_ algorithms.
# ```
"""
The succinct statement `cev ⋄ iv` is an expressive shorthand for 
[`CEvolution(cev, iv)`](@ref CEvolution).

# Implementation
Use `\\diamond` to get `⋄`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
cev = extremal_evolution(SIR(0, 1, 1, 0), 2.0, [1.0])
iv  = Innovation(2, [I(0.5, 1, 2)], R[], [C(1.0, 1)])
cev ⋄ iv

# output
CEvolution(SIR₀.₀₀(1:1:0),
infections: AbstractInfection[ℐ₀.₅₀¹ᑉ²]
removals:   AbstractRemoval[]
cremovals:  CRemoval[𝒞₁.₀₀¹]
chronology: AbstractIncident[ℐ₀.₅₀¹ᑉ²,𝒞₁.₀₀¹]
trajectory: SIR[SIR₀.₀₀(1:1:0),SIR₀.₅₀(0:2:0),SIR₁.₀₀(0:1:1)]
history:    AbstractIncident[ℐ₀.₅₀¹ᑉ²,𝒞₁.₀₀¹])
```
"""
function ⋄(cev::CEvolution, iv::AbstractInnovation)::CEvolution
    return CEvolution(cev, iv)
end

"""
This variant of [`⋄`](@ref ⋄)
applies a sequence of [`Innovation`](@ref Innovation)s 
to evolve each of
a tuple of [`CEvolution`](@ref CEvolution)s 
(typically just two, typically
produced using 
[`extremal_evolution`](@ref extremal_evolution)).
"""
function ⋄(states::Vector{CEvolution}, innovs::Vector{Innovation}) ::Vector{CEvolution}
    for iv in innovs
        for i in 1:length(states)
            states[i] = states[i] ⋄ iv
        end
    end
    return states
end


"""
Consider the action of an integer (or a `SIR`, or an `InnovationStart_sRWM`) on a `CEvolution` 
through `▷`. 
The succinct statement `cev ▷ sir` checks whether one can replace
`cev.initial.i` by `sir.i`.
This _includes_ checking whether the epidemic size, `cev.size` will not be exceeded,
if it is positive.
If checks OK, return resulting `CEvolution`. 
Otherwise, return original `CEvolution`.

# Implementation
Use ``\\triangleright` to get `▷`.

### Example 1
```jldoctest; setup = :(using EpidemicsCFTP)
cev = extremal_evolution(SIR(0, 1, 1, 0), 2.0, [1.0])
sir = SIR(0, 2, 0, 0)
cev ▷ sir

# output
CEvolution(SIR₀.₀₀(1:1:0),
infections: AbstractInfection[ℐ₀.₀₀¹ᑉ²]
removals:   AbstractRemoval[]
cremovals:  CRemoval[𝒞₁.₀₀²]
chronology: AbstractIncident[ℐ₀.₀₀¹ᑉ²,𝒞₁.₀₀²]
trajectory: SIR[SIR₀.₀₀(1:1:0),SIR₀.₀₀(0:2:0),SIR₁.₀₀(0:1:1)]
history:    AbstractIncident[ℐ₀.₀₀¹ᑉ²,𝒞₁.₀₀²])
```
### Example 2 (maximal)
```jldoctest; setup = :(using EpidemicsCFTP)
julia> cev = extremal_evolution(SIR(0, 2, 1, 0), 3.0, [1.0, 2.0], all_cremovals_observed=true) ;

julia> sir = SIR(0, 1, 2, 0) ; (cev.initial, cev.size)
(SIR(0.0, 2, 1, 0, 3), 2)
julia> ((cev ▷ sir).initial, cev.size)
(SIR(0.0, 1, 2, 0, 3), 2)
julia> sir = SIR(0, 0, 3, 0) ; ((cev ▷ sir).initial, cev.size)
(SIR(0.0, 2, 1, 0, 3), 2)
```
### Example 2 (minimal)
```jldoctest; setup = :(using EpidemicsCFTP)
julia> cev = extremal_evolution(SIR(0, 2, 1, 0), 3.0, [1.0, 2.0], all_cremovals_observed=true, maximal=false) ;

julia> sir = SIR(0, 1, 2, 0) ; (cev.initial, cev.size)
(SIR(0.0, 2, 1, 0, 3), 2)
julia> ((cev ▷ sir).initial, cev.size)
(SIR(0.0, 1, 2, 0, 3), 2)
julia> sir = SIR(0, 0, 3, 0) ; ((cev ▷ sir).initial, cev.size)
(SIR(0.0, 2, 1, 0, 3), 2)
```
"""
function ▷(cev::CEvolution, sir::SIR)::CEvolution
    return ▷(cev, sir.i)
end

"""    
Use `Int` directly instead of using `i` field in `SIR` for `▷(::CEvolution, ::SIR) ::CEvolution`.
"""
function ▷(cev::CEvolution, initial_infectives::Int)::CEvolution
    proposed_sir = alter_sir_infection(cev.initial, initial_infectives)
    if (proposed_sir == cev.initial) || (proposed_sir.i + proposed_sir.r > cev.size > 0)
        return cev
    end
    try
        new_cev = CEvolution(proposed_sir, cev.chronology, size=cev.size)
        return new_cev
    catch e
        if !((e isa EmployedRemoval) || (e isa MissedCRemoval))
            rethrow()
        end
        return cev
    end
end

"""
Use `InnovationStart_IS.proposal` in `▷(::CEvolution, ::Int)`.
"""
function ▷(cev::CEvolution, innovation_start::InnovationStart_IS)::CEvolution
    return ▷(cev, innovation_start.proposal)
end

"""
Consider the action of an `InnovationStart_sRWM` on a `CEvolution` 
through `▷`. This implements a proposal of a `shift` `±1` and accepts this
according to a (simple, symmetric) Random Walk Metropolis test (employing a 
`Uniform(0,1)` `mark` and a `prior` given by the `InnovationStart_sRWM`).

Note that the `prior` is assumed to be a `Categorical` distribution
over some range of integers `1:n`.

### Example
In this example, a shift of `-1` has no effect, as this would reduce total 
population to zero.
```jldoctest iv_RM; setup = :(using EpidemicsCFTP)
initial    = SIR(0.0, 3, 1, 0)
infections = [NF(0.2,3,4), NF(0.4,3,4), P(0.5,1,2), I(0.7,1,2)]
removals   = [R(0.1, 3), R(0.3, 3), R(0.8, 3)]
cremovals  = [C(0.6,1), C(0.9,2)]
chronology = infections ∪ removals ∪ cremovals
cev        = CEvolution(initial, chronology)
prior      = Categorical(Real[0.5, 0.3, 0.2])
(cev ▷ InnovationStart_sRWM(prior, 0.1, -1)).trajectory

# output
SIR[SIR₀.₀₀(3:1:0),SIR₀.₅₀(2:2:0),SIR₀.₆₀(2:1:1),SIR₀.₉₀(2:0:2)]
```
A shift of `+1` with a sufficiently small mark 
(here we use a zero `mark`!)
_does_ have an effect.
```jldoctest iv_RM
(cev ▷ InnovationStart_sRWM(prior, 0.0, 1)).trajectory

# output
SIR[SIR₀.₀₀(2:2:0),SIR₀.₆₀(2:1:1),SIR₀.₉₀(2:0:2)]
```
However a further application of the `InnovationStart_sRWM`
with shift `+1`
does not alter the conditioned epidemic (even with 
a zero `mark`), in fact because
the change would lead to an (unconditioned) removal
being activated.
```jldoctest iv_RM
cev1 = cev ▷ InnovationStart_sRWM(prior, 0.0, 1)
(cev1 ▷ InnovationStart_sRWM(prior, 0.0, 1)).trajectory

# output
SIR[SIR₀.₀₀(2:2:0),SIR₀.₆₀(2:1:1),SIR₀.₉₀(2:0:2)]
```
Note on the other hand that a _different_ further shift of `-1` _does_ have an effect,
reverting to the original trajectory.
```jldoctest iv_RM
(cev1 ▷ InnovationStart_sRWM(prior, 0.0, -1)).trajectory

# output
SIR[SIR₀.₀₀(3:1:0),SIR₀.₅₀(2:2:0),SIR₀.₆₀(2:1:1),SIR₀.₉₀(2:0:2)]
```
"""
function ▷(cev::CEvolution, proposal::InnovationStart_sRWM)::CEvolution
    current  = cev.initial.i
    p, mark = proposal.prior.p, proposal.mark
    proposed = current + proposal.shift
    if (proposed ≤ 0) || (0 < cev.size <= proposed) || (proposal.nmax < proposed)
        return cev
    elseif mark * p[current] > p[proposed]
        return cev
    else
        return cev ▷ alter_sir_infection(cev.initial, proposed)
    end
end

"""
Consider the action of an `InnovationStart_aRWM` on a `CEvolution` 
through `▷`. This implements a proposal of a `shift` `±1` 
(with probability `ρ` for `-`)
and accepts this
according to a (simple, symmetric) Random Walk Metropolis test (employing a 
`Uniform(0,1)` `mark` and a `prior` given by the `InnovationStart_aRWM`).

Note that the `prior` is assumed to be a `Categorical` distribution
over some range of integers `1:n`.

### Example
If `ρ==0.5` then we have the equivalent of an `InnovationStart_sRWM`.
```jldoctest iv_RM
initial    = SIR(0.0, 3, 1, 0)
infections = [NF(0.2,3,4), NF(0.4,3,4), P(0.5,1,2), I(0.7,1,2)]
removals   = [R(0.1, 3), R(0.3, 3), R(0.8, 3)]
cremovals  = [C(0.6,1), C(0.9,2)]
chronology = infections ∪ removals ∪ cremovals
cev        = CEvolution(initial, chronology)
prior      = Categorical(Real[0.5, 0.3, 0.2])
(cev ▷ InnovationStart_aRWM(prior, 0.5, 0.0, 1)).trajectory

# output
SIR[SIR₀.₀₀(2:2:0),SIR₀.₆₀(2:1:1),SIR₀.₉₀(2:0:2)]
```
```
"""
function ▷(cev::CEvolution, proposal::InnovationStart_aRWM)::CEvolution
    current  = cev.initial.i
    p, ρ, mark = proposal.prior.p, proposal.ρ, proposal.mark
    t_prob = proposal.shift == -1 ? ρ : 1 - ρ
    proposed = current + proposal.shift
    if (proposed ≤ 0) || (0 < cev.size <= proposed) || (proposal.nmax < proposed)
        return cev
    elseif mark * t_prob * p[current] > (1 - t_prob) * p[proposed]
        return cev
    else
        return cev ▷ alter_sir_infection(cev.initial, proposed)
    end
end


"""
Compares (weakly) two `AbstractEvolution`s
with the same population `initial.n`, by comparing the `start` fields.
Note that `ev1 ⪯ ev2` exactly when none of the activated infections of `ev1` precede
the respective activated infections of `ev2`, so that `ev1` proceeds no faster than `ev2`.

# Implementation
Use `\\preceq` to obtain `⪯`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
iv1 = Innovation(2, I[I(2,1,2)], R[])
iv2 = Innovation(2, I[I(1,1,2)], R[])
Evolution(initial, iv1) ⪯ Evolution(initial, iv2)

# output
true
```
"""
function ⪯(ev1::AbstractEvolution, ev2::AbstractEvolution) ::Bool
    ev1.initial.n == ev2.initial.n || return false
    return all(z1 ≥ z2 for (z1, z2) ∈ zip(ev1.start, ev2.start))
end
    
"""
Specializes 
[`⪯(::AbstractEvolution, ::AbstractEvolution)`](@ref),
comparing weakly two `CEvolution`s
with the same population `initial.n` _and_ the same `CRemoval` times,
comparing not only the `start` fields as in the `AbstractEvolution` version, 
but also checking that the `CRemoval` `target` fields in `ev1` are no higher
than the respective `CRemoval` `target` fields in `ev2`.  
### Examples
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
civ1 = Innovation(2, I[I(2,1,2)], R[], [C(3,1)])
civ2 = Innovation(2, I[I(1,1,2)], R[], [C(3,1)])
CEvolution(initial, civ1) ⪯ CEvolution(initial, civ2)

# output
true
```

```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
civ1 = Innovation(2, I[I(1,1,2)], R[], [C(3,1)])
civ2 = Innovation(2, I[I(1,1,2)], R[], [C(3,2)])
CEvolution(initial, civ1) ⪯ CEvolution(initial, civ2)

# output
true
```
"""
function ⪯(ev1::CEvolution, ev2::CEvolution) ::Bool
    any(ev1.initial.n != ev2.initial.n) && error("populations differ")
    pair = zip(ev1.cremovals, ev2.cremovals)
    any(z1.t != z2.t  for (z1, z2) ∈ pair) && error("cremoval times differ")
    timelines_ok = all(z1 ≥ z2 for (z1, z2) ∈ zip(ev1.start, ev2.start))
    crtargets_ok = all(z1.target ≤ z2.target for (z1, z2) ∈ pair)
    return timelines_ok && crtargets_ok 
end

"""
Tests equality (weakly) for two `AbstractEvolution`s
with the same population `initial.n`, using [`⪯`](@ref).
# Implementation
Use `\\simeq` to produce `≃`.
### Example
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
iv = Innovation(2, I[I(1,1,2)], R[])
Evolution(initial, iv) ≃ Evolution(initial, iv)

# output
true
```
"""
function ≃(ev1::AbstractEvolution, ev2::AbstractEvolution) ::Bool
    return (ev1 ⪯ ev2) && (ev2 ⪯ ev1)
end

"""
Checks whether two `AbstractEvolution`s are _equivalent_, meaning
their types agree and their constituent fields all agree. In the case
of `CEvolution` we also require agreement of the fields `LFE` and `NFZ`.
The third and fourth examples use this to test the phenomenon of
"idempotence": `cev1` differs from `cev2` and `cev3` because its
construction did not compute the fields `LFE` and `NFZ`.
# Implementation
Use `\\cong` to produce `≅`.
### Example
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
ev1 = Evolution(initial, Innovation(2, [I(2,1,2)], [R(1,2)]))
ev2 = Evolution(initial, AI[I(2,1,2), R(1,2)])
ev1 ≅ ev2

# output
true
```
### Example
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
ev1 = Evolution(initial, Innovation(2, [I(2,1,2)], [R(1,2)]))
ev2 = Evolution(initial, Innovation(2, [I(2,1,2)], R[]))
ev1 ≅ ev2

# output
false
```
### Idempotence (I)
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
iv   = Innovation(2, [I(2,1,2)], [R(1,2)], [C(3,2)])
cev1 = CEvolution(initial, iv)
cev2 = cev1 ⋄ iv 
cev1 ≅ cev2

# output
false
```
### Idempotence (II)
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
iv   = Innovation(2, [I(2,1,2)], [R(1,2)], [C(3,2)])
cev1 = CEvolution(initial, iv)
cev2 = cev1 ⋄ iv 
cev3 = cev2 ⋄ iv 
cev2 ≅ cev3

# output
true
```
"""
function ≅(ev1::AbstractEvolution, ev2::AbstractEvolution)
    return false
end
function ≅(ev1::Evolution, ev2::Evolution)
    return (ev1.initial == ev2.initial) &&
        (ev1.infections == ev2.infections) &&
        (ev1.removals == ev2.removals) &&
        (ev1.cremovals == ev2.cremovals) &&
        (ev1.size == ev2.size) && (ev1.t0 == ev2.t0) &&
        (ev1.duration == ev2.duration)
end
function ≅(ev1::CEvolution, ev2::CEvolution)
    return (ev1.initial == ev2.initial) &&
        (ev1.infections == ev2.infections) &&
        (ev1.removals == ev2.removals) &&
        (ev1.cremovals == ev2.cremovals) &&
        (ev1.size == ev2.size) && (ev1.t0 == ev2.t0) &&
        (ev1.duration == ev2.duration) &&
        (ev1.LFE == ev2.LFE) && (ev1.NFZ == ev2.NFZ)
end

# Total ordering of incidents
# ---------------------------
# To note: this ordering is a refinement of time-ordering!

"""
Compares two [`AbstractIncident`](@ref) quantities using time-order (`t` field):
[`AbstractIncident`](@ref) quantities with the same `t` field are further partially ordered as follows:
[`AbstractInfection`](@ref)s precede [`AbstractRemoval`](@ref)s,
then
(for [`Infection`](@ref),  [`PInfection`](@ref), ...)
`target` and `infectee`, 
or 
(for [`Removal`](@ref), [`CRemoval`](@ref), ...)
`target`. 
Finally, ties are broken by subtype as follows
(precomputed!),
```julia
    InfectionMarker < PInfection < Infection < NoFlyRemoval < KilledRemoval < 
        ExpungedRemoval < CRemoval < Removal < KilledRemoval < RemovalMarker
```
Thus two incidents of equal priority must be the same incident.

Notice that `PInfection` and `CRemoval` take priority in, respectively,
`AbstractInfection`s and `AbstractRemovals`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> C(0.10, 2) < R(0.10, 2)
true
julia> P(0.15, 2, 5) < I(0.15, 2, 5)
true
julia> P(0.15, 2, 5) < R(0.15, 3)
true
julia> I(0.15, 2, 5) < R(0.15, 3)
true
julia> R(0.10, 3) < C(0.10, 2)
false
julia> R(0.10, 3) > C(0.10, 2)
true
julia> P(0.15, 2, 7) < R(0.10, 3)
false
julia> P(0.10, 2, 7) < R(0.10, 3)
true
```
"""
function isless(x::AbstractIncident, y::AbstractIncident)
    if x.t != y.t
        return x.t < y.t
    end
    return (x isa AbstractInfection) && (y isa AbstractRemoval)
end

# Possible efficiency gain: implement as `Tuple`?
"""
Data to help determine total ordering for concrete [`AbstractIncident`](@ref) types.
"""
Removal_order = Dict(CRemoval => 1, Removal => 2, 
                     KilledRemoval => 3, RemovalMarker => 4)

"""
If both are `AbstractRemoval` then first consider `time` mark.
Then consider `target` mark.
Finally differentiate according to subtype of `AbstractRemoval` (this sub-ordering is pre-computed).
"""
function isless(x::AbstractRemoval, y::AbstractRemoval) 
    if x.t != y.t
        return x.t < y.t
    end
    if x.target != y.target
        return x.target < y.target
    end
    return Removal_order[typeof(x)] < Removal_order[typeof(y)]
end

# Possible efficiency gain: implement as `Tuple`?
Infection_order = Dict(InfectionMarker => 0, PInfection => 1, Infection => 2, 
                       NoFlyInfection => 3, KilledInfection => 4, ExpungedInfection => 5)

"""
If both are `AbstractInfection` then first consider `time` mark.
Then consider `target` mark.
Then consider `infectee` mark.
Finally differentiate according to subtype of `InfectionRemoval` (this sub-ordering is pre-computed).
"""
function isless(x::AbstractInfection, y::AbstractInfection) 
    # 
    if x.t != y.t
        return x.t < y.t
    end
    if x.target != y.target
        return x.target < y.target
    end
    if x.infectee != y.infectee
        return x.infectee < y.infectee
    end
    return Infection_order[typeof(x)] < Infection_order[typeof(y)]
end

# Altering an `SIR` infection field
# ---------------------------------
"""
Returns a modification of its first argument such that
the `i` field equals the second argument.
### Example 1
```jldoctest; setup = :(using EpidemicsCFTP)
import EpidemicsCFTP: alter_sir_infection
sir = SIR(0, 2, 0, 0)
alter_sir_infection(sir, 1)

# output
SIR₀.₀₀(1:1:0)
```
### Example 2
```jldoctest; setup = :(using EpidemicsCFTP)
import EpidemicsCFTP: alter_sir_infection
sir = SIR(0, 1, 0, 0)
alter_sir_infection(sir, 1)

# output
SIR₀.₀₀(0:1:0)
```
"""
function alter_sir_infection(sir::SIR, proposed_i::Int)::SIR
    return SIR(sir.t, sir.s + (sir.i - proposed_i), proposed_i, sir.r)
end


# Altering `CRemoval` timeline
# -------------------------------
"""
Produce a new [`AbstractRemoval`](@ref): same time `t` but changing
the mark `target` of the [`AbstractRemoval`](@ref) `rem`
to point to a positive `timeline` specified by the `Integer` argument.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> rem = C(0.15, 4)
𝒞₀.₁₅⁴

julia> alter(rem, 2)
𝒞₀.₁₅²

julia> rem = R(0.15, 4)
ℛ₀.₁₅⁴

julia> alter(rem, 2)
ℛ₀.₁₅²
```
"""
function alter(rem::AbstractRemoval, new_timeline::Integer)::AbstractRemoval
    if  0 < new_timeline
        typeof(rem)(rem.t, new_timeline)
    else
        throw(ArgumentError("cannot give $rem a non-positive new timeline $new_timeline"))
    end
end

# Check if incident is activatable
# -------------------------------
"""
Tests whether an incident should be activated for a given state.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), I(0.1, 4, 6))
true
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), XI(0.1, 4, 6))
false
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), I(0.1, 4, 5))
false
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), R(0.1, 4))
true
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), KR(0.1, 4))
false
julia> EpidemicsCFTP.is_activatable(SIR(0.0, 1, 2, 3), R(0.1, 6))
false
```
"""
function is_activatable(state::SIR, z::AbstractInfection)::Bool
    z isa OperativeInfection && 
        z.t >= state.t && z.target > state.r && z.infectee == state.i + state.r + 1
end,
function is_activatable(state::SIR, z::AbstractRemoval)::Bool
    z isa OperativeRemoval && 
        z.t >= state.t && z.target > state.r && z.target <= state.i + state.r
end

# Activate an infection
# -------------------------------
"""
Change state of a `S-I-R` epidemic to activate an infection at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.infect(0.1, SIR(0.0, 1, 2, 3))
SIR₀.₁₀(0:3:3)
```
"""
function infect(t::Real, state::SIR)::SIR
    SIR(t, state.s - 1, state.i + 1, state.r)
end

# Activate a removal
# -------------------------------
"""
Change state of a `S-I-R` epidemic to activate a removal at time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.remove(0.1, SIR(0.0, 1, 2, 3))
SIR₀.₁₀(1:1:4)
```
"""
function remove(t::Real, state::SIR)::SIR
    SIR(t, state.s, state.i - 1, state.r + 1)
end

# Update using an incident
# -------------------------------
"""
Applies [`AbstractIncident`](@ref)
to a given state and returns resulting state if it is activated (and hence operative).
Otherwise returns original state but with updated time `t`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), R(0.2, 4))
SIR₀.₂₀(1:1:4)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), KR(0.2, 4))
SIR₀.₂₀(1:2:3)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), I(0.2, 4, 6))
SIR₀.₂₀(0:3:3)
julia> EpidemicsCFTP.update(SIR(0.1, 1, 2, 3), XI(0.2, 4, 6))
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

# Updating in reverse time
# -------------------------------
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


# Test if two configurations agree (except for time!)
# -------------------------------
"""
Checks if the two [`SIR`](@ref) states have the same values for `s`, `i`, `r` fields
(but not `t` field).

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> EpidemicsCFTP.is_same_config(SIR(0.1, 1, 2, 3), SIR(0.9, 1, 2, 3))
true
```
"""
function is_same_config(state1::SIR, state2::SIR)::Bool
    state1.s == state2.s && state1.i == state2.i && state1.r == state2.r
    end

# Evolve an epidemic
# -------------------------------
"""
Evolve a `S-I-R` epidemic from an initial [`SIR`](@ref) state using
an [`AbstractIncident`](@ref) vector. Returns
a list of `SIR` states and a history `Vector{AbstractIncident}` of realized incidents.
**NOTE:** 

 * the evolution starts at the time of the initial state! Earlier incidents are ignored.
 * it is assumed that the `Vector{<:AbstractIncident}` is ordered by increasing value of `t`.

If the keyword argument `conditioned` is set to its non-default value of `true`
then an error is raised when the function attempts to realize a [`Removal`](@ref)
or fails to realize a [`CRemoval`](@ref).

This method is employed in the construction of [`Evolution`](@ref)
and (with the `conditioned` flag set to `true`) [`CEvolution`](@ref) objects.

### Example
```jldoctest evolution; setup = :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations)
julia> initial_state = SIR(0.01, 1, 2, 3) ; population = 6 ;

julia> innovation = Innovation(population, [I(0.6, 5, 6)], R[R(0.5, 4)], C[]) ;

julia> states, history = evolution(initial_state, innovation) ;

julia> states
SIR[SIR₀.₀₁(1:2:3),SIR₀.₅₀(1:1:4),SIR₀.₆₀(0:2:4)]

julia> history
AbstractIncident[ℛ₀.₅₀⁴,ℐ₀.₆₀⁵ᑉ⁶]
```
"""
function evolution(initial_state::SIR, chronology::Vector{<:AbstractIncident}; 
                    conditioned::Bool=false) ::Tuple{Vector{SIR},Vector{AbstractIncident}}
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
Evolve a `S-I-R` epidemic from an initial [`SIR`](@ref) state using
an [`Innovation`](@ref). Returns
a list of `SIR` states and a history `Vector{AbstractIncident}` of realized incidents.
**NOTE:** 

 * the evolution starts at the time of the initial state! Earlier incidents are ignored.

If the keyword argument `conditioned` is set to its non-default value of `true`
then an error is raised when the function attempts to realize a [`Removal`](@ref)
or fails to realize a [`CRemoval`](@ref).

### Example
I: Basic use, conditioned (A)
```jldoctest cevolution; setup = :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations)
julia> initial_state = SIR(0.01, 1, 2, 3) ; population = 6 ;

julia> innovation = Innovation(population, [I(0.6, 5, 6)], R[R(0.5, 4)], C[]) ;

julia> evolution(initial_state, innovation, conditioned=true)
ERROR: [EmployedRemoval] The (conditioned) evolution wrongly employed Removal(0.5, 4)

julia> innovation = Innovation(population, [I(0.6, 5, 6)], R[], [C(0.5, 4)]) ;

julia> states, history = evolution(initial_state, innovation) ;

julia> states
SIR[SIR₀.₀₁(1:2:3),SIR₀.₅₀(1:1:4),SIR₀.₆₀(0:2:4)]

julia> history
AbstractIncident[𝒞₀.₅₀⁴,ℐ₀.₆₀⁵ᑉ⁶]
```

II: Basic use, conditioned (B)
```jldoctest cevolution
julia> innovation = Innovation(population, [I(0.6, 5, 6)], R[], [C(0.5, 1)]) ;

julia> evolution(initial_state, innovation, conditioned=true) ;
ERROR: [MissedCRemoval] The (conditioned) evolution failed to employ CRemoval(0.5, 1)

julia> initial_state = SIR(0.55, 1, 2, 3) ;

julia> answer = evolution(initial_state, innovation, conditioned=true) ;

julia> answer[1]
SIR[SIR₀.₅₅(1:2:3),SIR₀.₆₀(0:3:3)]
julia> answer[2]
AbstractIncident[ℐ₀.₆₀⁵ᑉ⁶]
```
"""
function evolution(initial_state::SIR, innovation::AbstractInnovation; conditioned::Bool=false) ::Tuple{Vector{SIR},Vector{AbstractIncident}}
    return evolution(initial_state, innovation.chronology; conditioned=conditioned)
end


    
"""
Evolves a `S-I-R` epidemic from an initial [`SIR`](@ref) state using
an [`AbstractInnovation`](@ref). Returns
only the _history_ of realized incidents `Vector{AbstractIncident}`.
**NOTE:** the evolution starts at the time of the initial state! Earlier incidents are ignored.

If the keyword argument `conditioned` is set to its non-default value of `true`
then an error is raised when the function attempts to realize a [`Removal`](@ref)
or fails to realize a [`CRemoval`](@ref).

Note that this method may later be employed in the construction of [`Evolution`](@ref)
and (with the `conditioned` flag set to `true`) [`CEvolution`](@ref) objects.

### Example
I: Basic use, unconditioned
```jldoctest evolution_history; setup = :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations)
julia> initial_state = SIR(0.01, 1, 2, 3) ; population = 6 ;

julia> innovation = Innovation(population, [I(0.6, 5, 6)], R[R(0.5, 4)], C[]) ;

julia> evolution_history(initial_state, innovation)
AbstractIncident[ℛ₀.₅₀⁴,ℐ₀.₆₀⁵ᑉ⁶]
```

II: Basic use, conditioned (A)
```jldoctest evolution_history
julia> evolution_history(initial_state, innovation, conditioned=true)
ERROR: [EmployedRemoval] The (conditioned) evolution wrongly employed Removal(0.5, 4)

julia> innovation = Innovation(population, [I(0.6, 5, 6)], R[], [C(0.5, 4)]) ;

julia> evolution_history(initial_state, innovation)
AbstractIncident[𝒞₀.₅₀⁴,ℐ₀.₆₀⁵ᑉ⁶]
```

III: Basic use, conditioned (B)
```jldoctest evolution_history
julia> innovation = Innovation(population, [I(0.6, 5, 6)], R[], [C(0.5, 1)]) ;

julia> evolution_history(initial_state, innovation, conditioned=true) ;
ERROR: [MissedCRemoval] The (conditioned) evolution failed to employ CRemoval(0.5, 1)

julia> initial_state = SIR(0.55, 1, 2, 3) ;

julia> evolution_history(initial_state, innovation, conditioned=true)
AbstractIncident[ℐ₀.₆₀⁵ᑉ⁶]
```
"""
function evolution_history(initial_state::SIR, innovation::AbstractInnovation; conditioned::Bool=false) ::Vector{AbstractIncident}
    return evolution_history(initial_state, innovation.chronology; conditioned=conditioned)
end,
function evolution_history(initial_state::SIR, chronology::Vector{<:AbstractIncident}; conditioned::Bool=false) ::Vector{AbstractIncident}
    
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

# Creating an extremal `CEvolution`
# ---------------------------------
"""
Create an extremal `CEvolution`, placing `CRemoval`s at the times specified by the third argument,
and giving them targets which are maximal (`initial.n`) if keyword `maximal=true`, otherwise
minimal (`i`-th `CRemoval` has target `i`). Infections are placed at the time of each `CRemoval`
hence immediately prior in time, because of the defined total ordering for `AbstractIncident`s.

If the keyword `all_cremovals_observed=true` then the number of `Infection`s in the
maximal version is limited to the number of `CRemoval`s less the initial number infected.

Note also that, strictly speaking, in the minimal version there should be an infinitely dense
arrangement of `Removal`s on uninfected parts of the time lines. We omit this because these
would be immediately removed in the first step of evolution in algorithmic time.

### Example (maximal)
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
extremal_evolution(initial, 3.0, [1.0, 2.0])

# output
CEvolution(SIR₀.₀₀(2:1:0),
infections: AbstractInfection[ℐ₀.₀₀¹ᑉ²,ℐ₀.₀₀²ᑉ³]
removals:   AbstractRemoval[]
cremovals:  CRemoval[𝒞₁.₀₀³,𝒞₂.₀₀³]
chronology: AbstractIncident[ℐ₀.₀₀¹ᑉ²,ℐ₀.₀₀²ᑉ³,𝒞₁.₀₀³,𝒞₂.₀₀³]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(1:2:0),SIR₀.₀₀(0:3:0),SIR₁.₀₀(0:2:1),SIR₂.₀₀(0:1:2)]
history:    AbstractIncident[ℐ₀.₀₀¹ᑉ²,ℐ₀.₀₀²ᑉ³,𝒞₁.₀₀³,𝒞₂.₀₀³])
```
### Example (minimal)
```jldoctest; setup = :(using EpidemicsCFTP)
initial = SIR(0.0, 2, 1, 0)
extremal_evolution(initial, 3.0, [1.0, 2.0]; maximal=false)

# output
CEvolution(SIR₀.₀₀(2:1:0),
infections: AbstractInfection[ℐ₁.₀₀¹ᑉ²]
removals:   AbstractRemoval[]
cremovals:  CRemoval[𝒞₁.₀₀¹,𝒞₂.₀₀²]
chronology: AbstractIncident[ℐ₁.₀₀¹ᑉ²,𝒞₁.₀₀¹,𝒞₂.₀₀²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₁.₀₀(1:2:0),SIR₁.₀₀(1:1:1),SIR₂.₀₀(1:0:2)]
history:    AbstractIncident[ℐ₁.₀₀¹ᑉ²,𝒞₁.₀₀¹,𝒞₂.₀₀²])
```
### Example (size, maximal)
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial = SIR(0.0, 2, 1, 0) ;

julia> cev = extremal_evolution(initial, 3.0, [1.0, 2.0], all_cremovals_observed=true) ;

julia> cev.size
2
```
### Example (size, minimal)
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial = SIR(0.0, 2, 1, 0) ;

julia> cev = extremal_evolution(initial, 3.0, [1.0, 2.0], all_cremovals_observed=true, maximal=false) ;

julia> cev.size
2
```
"""
function extremal_evolution(initial::SIR, duration::Real, times::Vector{<:Real};
                size::Int=-1, α::Real=-1.0, β::Real=-1.0,
                maximal::Bool=true, all_cremovals_observed::Bool=false) ::CEvolution
    t0         = initial.t
    starter    = initial.r + initial.i
    population = initial.n
    if maximal
        if all_cremovals_observed
            infections = [Infection(t0,i,i+1) for i ∈ starter:(length(times)-1)]
            cremovals  = [C(t, length(times)) for t in times]
        else
            infections = [I(t0,i,i+1) for i ∈ starter:(population-1)]
            cremovals  = [C(t, population) for t in times]
        end
    else
        sort(deepcopy(times))
        infections = [I(times[i],i,i+1) for i ∈ starter:(length(times)-1)]
        cremovals  = [C(t, i) for (i, t) in enumerate(times)]
    end
    if all_cremovals_observed && size < 0 
        size = length(cremovals) + initial.r
    end
    return CEvolution(initial, convert(Vector{AI}, infections ∪ cremovals);
                t0=t0, duration=duration, size=size)
end

# Computing the laziest feasible epidemic trajectory
# -----------------------------------------------
"""
Compute the laziest feasible epidemic trajectory relevant for a [`CEvolution`](@ref) which will be updated
by a [`AbstractInnovation`](@ref). This is used when constructing a [`CEvolution`](@ref) 
from an [`AbstractEvolution`](@ref)
and an [`AbstractInnovation`](@ref): see examples I and II. Example III gives an explicit use, in a partial correctness test 
(see [`is_correct_LFE`](@ref) for a complementary and more challenging test).

### Example I
```jldoctest
initial = SIR(0.0, 2, 1, 0)
innov = Innovation(3, 
    I[I(1.0, 1, 2)], 
    R[R(1.0, 3)], 
    C[C(2.0, 1)])
cev = CEvolution(initial, AI[I(1.0, 1, 3), R(1.0, 3), C(2.0, 1)])
CEvolution(cev, innov).LFE

# output
AbstractIncident[𝒞₂.₀₀¹]
```

### Example II
```jldoctest LFE_test; setup = :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations, Random)
Random.seed!(43) 
duration, population = 5.0, 5
α, β = 0.2, 0.1
cremoval_times = [1.0, 2.0, 3.0, 4.0] 
initial = SIR(0, population - 1, 1, 0) 
ev  = extremal_evolution(initial, duration, cremoval_times)
iv0 = Innovation(population, I[], R[], ev.cremovals; duration=duration, α=α, β=β)
iv  = rand(iv0)
evx = CEvolution(ev, iv)
evx.LFE

# output
AbstractIncident[𝒫₀.₀₀¹ᑉ²,ℐ₀.₈₅²ᑉ³,ℐ₀.₉₆³ᑉ⁴,𝒞₁.₀₀⁴,𝒞₂.₀₀⁴,ℐ₂.₁₆⁴ᑉ⁵,𝒞₃.₀₀³,𝒞₄.₀₀⁵]
```

### Example III
Here is a simple test for validity of the `LFE` field.
```jldoctest LFE_test
import EpidemicsCFTP: laziest_feasible_evolution
laziest_feasible_evolution(duration, evx, iv) == evx.LFE

# output
true
```
"""
function laziest_feasible_evolution(duration::Real, 
    ev::AbstractEvolution, iv::AbstractInnovation,
    resampled_cremovals::Vector{CRemoval}) ::Vector{AbstractIncident}
# import EpidemicsCFTP: laziest_feasible_evolution
        
    previous_active_infections  = [P(z) for z in ev.history if z isa OperativeInfection]   # <1>
    chron1 = sort(iv.infections ∪ previous_active_infections ∪ resampled_cremovals)        # <2>
    removal_boundary =
        accumulate(+, z isa CRemoval ? 1 : 0 for z in chron1, init=ev.initial.r)           # <3>

    chron2 = [z isa OperativeInfection && z.target ≤ rb ? KilledInfection(z) : z
            for (z, rb) in zip(chron1, removal_boundary)]                                  # <4>
    chron3 = filter(z -> !(z isa KilledInfection), chron2)                                 # <5>

    removal_fence = 
        accumulate(max, z isa CRemoval ? z.target : 1 for z in chron3)                     # <6>

    current_timeline = removal_fence[end]
    reverse_LFE = AbstractIncident[]
    for (z, rf) in Iterators.reverse(zip(chron3, removal_fence))                           # <7>
        if z isa CRemoval
            push!(reverse_LFE, z)
        elseif z isa OperativeInfection && 
                current_timeline > max(ev.initial.i, rf) &&
                z.infectee == current_timeline 
            push!(reverse_LFE, z)
            current_timeline -= 1
        end
    end
    return reverse(reverse_LFE) 
end
function laziest_feasible_evolution(duration::Real, 
    ev::AbstractEvolution, iv::AbstractInnovation) ::Vector{AbstractIncident}
# import EpidemicsCFTP: resulting_cremovals
    laziest_feasible_evolution(duration, ev, iv, resulting_cremovals(ev, iv))              # <8>
end
# 1. For each `OperativeInfection` in the `history` of the previous `CEvolution`, 
# create a `PInfection` in a new list.
# Note that the argument here is that if any of these get used then it must be because of perpetuation,
# and perpetuation can only apply to `OperativeInfection`s that get into this previous `history`!
# 2. Generate a new `candidate_chronology`.
# 3. The `removal_boundary` uses the `CRemoval`s (times and activations guaranteed by conditioning!)
# in an accumulation which counts the number of removed time lines at each incident of 
# the `candidate_chronology`. 
# 4. Convert to `KilledInfection`s all `OperativeInfection`s which would not be activated by reason 
# of having `target` field at or below the `removal_boundary`.
# 5. Prune down to the `chron3` by removing all `KilledInfection`s.
# 6. Work through relevant chronology and the sequence of fences that have to be overcome.
# 7. Finally work backwards in time through the `chron3` to create `reverse_LFE`,
# which is a reversal of the final `LFE` that will eventually be returned.
# 8. Re-sample `CRemoval`s if they are not supplied in the arguments.
   
# Compute infectious interval for each time line
# ----------------------------------------------
"""
Return Vector of `AbstractIncident`s possibly using `InfectionMarker`
to list the left-most ends of infectious intervals of time lines.

### Example
```jldoctest
initial = SIR(0.0, 2,2,3)
history = AbstractIncident[R(0.5, 4), I(0.6, 5, 6)] 
start   = EpidemicsCFTP.create_start(initial, history) 

# output
AbstractInfection[ℳᑉ[-∞]⁰ᑉ¹,ℳᑉ[-∞]¹ᑉ²,ℳᑉ[-∞]²ᑉ³,ℳᑉ[-∞]³ᑉ⁴,ℳᑉ[-∞]⁴ᑉ⁵,ℐ₀.₆₀⁵ᑉ⁶,
    ℳᑉ[∞]⁶ᑉ⁷]

```
"""
function create_start(z0::SIR, hist::Vector{AbstractIncident})::Vector{AbstractInfection}
    # Use abbreviations (agrees with those in sub-module `abbreviations`).
    AIF, OI, IM = AbstractInfection, OperativeInfection, InfectionMarker
    
    # Compute initial infection incidents:
    # If time line `k` is strictly higher than the ultimate number infected,
    # then `start` time is `+Inf` (this is precisely when it will never be infected).
    # Otherwise `finis` time is provisionally set to `-Inf`.
    start = AIF[k > z0.r + z0.i ? IM(Inf, k-1, k) : IM(-Inf, k-1, k) for k in 1:z0.n]
    
    # Over-write for known infection incidents the history `hist`.
    for x ∈ [z for z ∈ hist if z isa OI]
            start[x.infectee] = x
    end

    return start
end
    
"""
Return Vector of `AbstractIncident`s (possibly using `RemovalMarker`) 
to list the right-most ends of infectious intervals of time lines.

Note that this currently presumes epidemic start and end incidents are marked
out by first argument `trajectory`.

### Example
```jldoctest
initial = SIR(0.0, 2,2,3)
history = AbstractIncident[R(0.5, 4), I(0.6, 5, 6)] 
EpidemicsCFTP.create_finis(initial, history) 

# output
AbstractRemoval[ℳ⁺[-∞]¹,ℳ⁺[-∞]²,ℳ⁺[-∞]³,ℛ₀.₅₀⁴,ℳ⁺[∞]⁵,ℳ⁺[∞]⁶,ℳ⁺[∞]⁷]
```
"""
function create_finis(z0::SIR, hist::Vector{AbstractIncident})::Vector{AbstractRemoval}
    # Use abbreviations (agrees with those in sub-module `abbreviations`).
    AIR, OR, RM = AbstractRemoval, OperativeRemoval, RemovalMarker
    
    # Compute final removal times:
    # If time line `k` is lower than or equal to the initial number removed,
    # then `finis` time is `-Inf` (this is precisely when it has been removed before start).
    # Otherwise `finis` time is provisionally set to `Inf`.
    finis = AIR[k ≤ z0.r ? RM(-Inf, k) : RM(Inf, k) for k in 1:z0.n]
    
    # Over-write for known removal incidents using the history `hist`.
    for (k, x) ∈ enumerate([z for z ∈ hist if z isa OR])
        finis[z0.r + k] = x
    end
   
    return finis
end


# Kill irrelevant infections and removals
# -------------------------------
"""
Examine [`AbstractInfection`](@ref)s from [`AbstractInnovation`](@ref) and determines which
are irrelevant (occurring in removal zone for [`AbstractEvolution`](@ref)). converting these
to [`KilledRemoval`](@ref)s.
"""
function kill_irrelevant_infections(ev::AbstractEvolution, iv::AbstractInnovation)::Vector{AbstractInfection}
    [ z ≤ ev.finis[z.target] ? z : KilledInfection(z) for z ∈ iv.infections ]
end ;

"""
Examine [`AbstractRemoval`](@ref)s from [`AbstractInnovation`](@ref) and determines which
are irrelevant (occurring in removal zone for [`Evolution`](@ref)). converting these
to [`KilledRemoval`](@ref)s.
"""
function kill_irrelevant_removals(ev::AbstractEvolution, iv::AbstractInnovation)::Vector{AbstractRemoval}
    [ z ≤ ev.finis[z.target] ? z : KilledRemoval(z) for z ∈ iv.removals ]
end ;

# Identify relevant infections
# -------------------------------
"""
Examine [`AbstractInfection`](@ref)s from [`AbstractInnovation`](@ref) and return
those which are relevant to construction of the "laziest feasible epidemic",
to wit, old infections in `ev.infections` used in `ev.history` plus new
infections in `iv.infections` which are not irrelevant (see [`kill_irrelevant_infections`](@ref))
and whose `target` is infected and whose `infectee` is susceptible.
"""
function relevant_infections(ev::AbstractEvolution, iv::AbstractInnovation)::Vector{AbstractInfection}
    unkilled = [z for z ∈ kill_irrelevant_infections(ev, iv) if z isa OperativeInfection]
    relevant_infections = [z for z ∈ ev.history if typeof(z) <: AbstractInfection]
    rsup = 0
    for z ∈ sort(ev.cremovals ∪ unkilled)
        if (typeof(z) == CRemoval) && (z.target > rsup)
            rsup = z.target
        elseif typeof(z) <: AbstractInfection &&
                ev.start[z.target] ≤ z < ev.finis[z.target] && z.infectee > rsup
            push!(relevant_infections, z)
        end
    end
    return sort(relevant_infections)
end 
    
# Extract and classify inactive removals
# -------------------------------
"""
Extract and classify the inactive [`AbstractRemoval`](@ref)s 
from an [`AbstractEvolution`](@ref).
Those which lie in the removals zone are converted to [`KilledRemoval`](@ref)s.

### Example
```jldoctest
julia> initial_state = SIR(0.55, 1, 2, 3) ; n = 6 ;

julia> innovation = Innovation(n, [I(0.6, 5, 6)], R[R(0.5, 4)], C[]) ;

julia> ev = Evolution(initial_state, innovation) ;

julia> rem = R[R(0.56, 1), R(0.57, 2), R(0.58, 6)]
Removal[ℛ₀.₅₆¹,ℛ₀.₅₇²,ℛ₀.₅₈⁶]
julia> innov2 = Innovation(n, [I(0.6, 5, 6)], rem, [C(0.5, 1)]) ;

julia> EpidemicsCFTP.inactive_removals(ev, innov2)
AbstractRemoval[𝒦₀.₅₆¹,𝒦₀.₅₇²,ℛ₀.₅₈⁶]
```
"""
function inactive_removals(ev::AbstractEvolution, innov::AbstractInnovation)::Vector{AbstractRemoval}
    return [ev.finis[z.target] ≤ z ? KilledRemoval(z) : z for z ∈ innov.removals if 
            ! (ev.start[z.target] < z < ev.finis[z.target])]
end    

# Accept/reject procedure
# -------------------------------

"""
Perform an accept/reject procedure: accept the [`CRemoval`](@ref) `proposed_cremoval` only if it would actually
be activated based on period `start`s and `finis`s
(expected to be generated by [`create_start`](@ref) and [`create_finis`](@ref) respectively): 
otherwise retain the [`CRemoval`](@ref) `old_cremoval`.
"""
function accept_reject(old_cremoval::CRemoval, proposed_cremoval::CRemoval,
                       start::Vector{AbstractInfection}, finis::Vector{AbstractRemoval})::CRemoval
    k = proposed_cremoval.target
    return start[k] ≤ proposed_cremoval ≤ finis[k] ? proposed_cremoval : old_cremoval
end

"""
Use [`accept_reject`](@ref) to determine re-sampled set of [`CRemoval`](@ref)s
(perhaps extracted from [`AbstractInnovation`](@ref)).
This uses the period markers
generated by [`create_start`](@ref) and [`create_finis`](@ref) respectively
from the [`AbstractEvolution`](@ref) `ev`.  
Note that `start` and `finis` are generated
when `ev` is constructed.
"""
function resulting_cremovals(ev::AbstractEvolution, iv::AbstractInnovation)::Vector{CRemoval}
    resulting_cremovals(ev, iv.cremovals)
end,
function resulting_cremovals(ev::AbstractEvolution, cr::Vector{CRemoval})::Vector{CRemoval}
    [accept_reject(oldcr, propcr, ev.start, ev.finis) 
        for (oldcr, propcr) ∈ zip(ev.cremovals, cr)]
end


# # Compute nofly zone
# # ------------------

"""
Compute the "true" boundary (`nofly_bound` in the code
of function `compute_nofly`): commented-out
works backwards through the new `Infection`s 
as explained in annotations of the source-code
while actual is taken from `CEvolution(::AbstractEvolution, ::AbstractInnovation)`. 

### Example
```jldoctest CEvolution; setup = :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations)
import EpidemicsCFTP: inactive_removals, laziest_feasible_evolution, compute_nofly
initial = SIR(0,1,1,0)
ev = CEvolution(initial, AI[C(4,1)])
iv = Innovation(2, AI[I(4.2,1,2), R(4.9,2), C(4,1)])
LFE = laziest_feasible_evolution(5, ev, iv)
perpetuated = P[z for z ∈ LFE if z isa P]
NFZ1 = repeat([-Inf], ev.initial.n)
for z ∈ [z for z ∈ inactive_removals(ev, iv) if z < ev.finis[z.target]]
    NFZ1[z.target] = max(NFZ1[z.target], z.t)
end
NFZ2 = accumulate(max, NFZ1)
compute_nofly(ev, iv.infections ∪ perpetuated, NFZ2)[2]

# output
2-element Vector{Float64}:
 -Inf
   4.9
```

Note the source-code also contains many commented-out assertions!
"""
function compute_nofly(ev::CEvolution, infections::Vector{<:AbstractInfection}, 
    NFZ2::Vector{<:Real}) ::Tuple{Vector{AbstractInfection},Vector{<:Real}} 
    
	nofly_bound = deepcopy(NFZ2)                                               # <1>
	processed_infections = AbstractInfection[]                                 # <2>
	 
	for z ∈ reverse(sort(infections))                                          # <3> 
	    
	    if (z ≥ ev.finis[z.target])                                            # <4>
	        push!(processed_infections, KI(z))                                 # <4>
            # @info "$(KI(z))"                                                 # <4>
            continue
	    end                                                                    # <4>
	    
	    # @assert(z < ev.finis[z.target])
        if (z.t ≥ nofly_bound[z.infectee])                                     # <5>
	        push!(processed_infections, z)                                     # <5>
	        continue                                                           # <5>
	    end                                                                    # <5>
	    
	    # @assert(z   < ev.finis[z.target])
	    # @assert(z.t < nofly_bound[z.infectee])
        if (z.t < nofly_bound[z.infectee - 1])                                 # <6>
	        push!(processed_infections, z)                                     # <6>
	        continue                                                           # <6>
	    end                                                                    # <6>
	    
	    # @assert(z.t < nofly_bound[z.infectee])
	    # @assert(z.t ≥ nofly_bound[z.infectee - 1])
	    # @assert(z   < ev.finis[z.target])
	    if (z ≥ ev.start[z.target])                                            # <7>
            if (z < ev.start[z.infectee - 1])                                  # <8>
                nofly_bound[z.infectee - 1] = z.t                              # <8>
                push!(processed_infections, NF(z))                             # <8>
                # @info "$(NF(z))"
                continue                                                       # <8>
            else                                                               # <8>
                push!(processed_infections, XI(z))                             # <8>
                # @info "$(XI(z))"
                continue                                                       # <8>
            end                                                                # <8>
	    end
	    
	    # @assert(z.t < nofly_bound[z.infectee])
	    # @assert(z.t ≥ nofly_bound[z.infectee - 1])
	    # @assert(z   < ev.start[z.target])
	    nofly_bound[z.infectee - 1] = z.t                                      # <9>
	    push!(processed_infections, NF(z))
        # @info "$(NF(z))"
	
	end
	
	return processed_infections, nofly_bound
end ;
# 1. The boundary `nofly_bound` will be updated recursively.
# 2. The list `processed_infections` of processed `AbstractInfection`s will
# eventually store (initially in reverse time order) a transformation of
# each infection supplied by the new `AbstractInnovation` `iv`.
# 3. Iteration: work backwards through `Infection`s supplied by `iv`,
# determining in each case how to transform the supplied `Infection`
# when adding it to the list `processed_infections`.
# 4. If the `Infection` `z` has `target` on the removed portion of a level
# then it will never be activated, so add `z` as a `KilledInfection`.
# 5. If the `Infection` `z` potentially infects a level at a _later time_ 
# than the current `NFZ2` at that level, then its activation will
# never break the conditioning (**needs proof!**), so add `z` as-is
# and continue to next step in the loop.
# (I think the point is: since we are working backwards in time, once
# `z.t` is considered then `NFZ2` is frozen from time `t` onwards.)
# 6. However if `z.t < NFZ2[z.infectee - 1]` then no issue can arise, as 
# infection of the level immediately below `z.infectee` will then not be
# allowed at this time. So again add `z` as-is and continue to next step in the loop.
# 7. Suppose `z ≥ ev.start[z.target]`: then an issue would arise
# if the level at `z.infectee - 1` were to become infected before
# `z.t`. One of two cases must hold:
# 8. Case (a): Suppose `z < ev.start[z.infectee - 1]`.
# Then **increase** `NFZ2[z.infectee - 1]` to `z.t` in order to
# preclude the time line getting infected, and also transform `z` to a
# `NoFlyInfection` when added to `processed_infections`, to signal
# that it should never become infected.  
# Case (b): Suppose `z ≥ ev.start[z.infectee - 1]`.
# Then increasing `NFZ2[z.infectee - 1]` to `z.t` would lead to a
# problem, since this level is infected at time `z.t`. Therefore we
# transform `z` to a `ExpungedInfection` when we add it to 
# `processed_infections`, so that it is treated as an
# `InoperativeInfection`.
# Either way, continue to next step in the loop.
# 9. Consider now that potential `Infection`s to be treated later in this
# iteration must have time mark earlier than `z.t`. If one of these were
# to infect the level `z.infectee - 1` then it would follow by monotonicity
# that the `z.target` level would become infected by that time `z.t`; and 
# thus would create an infection of the `z.infectee` level at time `z.t`. 
# In order for this to be prevented, we need to extend the `NFZ2` 
# at level `z.infectee - 1` up to time `z.t`. We also transform `z`
# to a `NoFlyInfection` when we add it to `processed_infections`, to
# signal that it should never become infected.

# Debugging functions
# -------------------

"""
Check that the `LFE` field of a [`CEvolution`](@ref) is genuinely a 
_laziest feasible evolution_. (Use primarily to **verify** that a
given `LFE` field is correct.) The example indicates usage. 
See example III from the doctests for [`laziest_feasible_evolution`](@ref) for
a further simple complementary test using that function.
### Example
```jldoctest
import Random
import EpidemicsCFTP: is_correct_LFE
Random.seed!(43) 
duration, population = 5.0, 5
α, β = 0.2, 0.1
cremoval_times = [1.0, 2.0, 3.0, 4.0] 
initial = SIR(0, population - 1, 1, 0) 
ev  = extremal_evolution(initial, duration, cremoval_times)
iv0 = Innovation(population, I[], R[], ev.cremovals; duration=duration, α=α, β=β)
iv  = rand(iv0)
evx = CEvolution(ev, iv)
is_correct_LFE(evx)

# output
true
```
"""
function is_correct_LFE(ev::CEvolution; debug::Bool=false)::Bool
# import EpidemicsCFTP: evolution, evolution_history, NonMinimalLFE, MissedCRemoval, EmptyLFE
    isempty(ev.LFE) ? throw(EmptyLFE(ev)) : nothing

    cycle = evolution(ev.initial, ev.LFE)[1]                                                        # <1>
    (state, pointer) = iterate(cycle)
    @debug println("state:     ", sprint(show, MIME("text/plain"), ev.history)) 
    @debug println("state:     ", sprint(show, MIME("text/plain"), ev.LFE)) 
    @debug println("state:     ", sprint(show, MIME("text/plain"), sort(ev.history ∪ ev.LFE)))
    for z ∈ sort(ev.history ∪ ev.LFE)                                                               # <2>
        if z ∈ ev.LFE
            @debug println("state:     ", sprint(show, MIME("text/plain"), (z, state)))
        end
        if z ∈ ev.LFE && z isa OperativeInfection                                                   # <3>
            chron0 = filter(!=(z), ev.chronology)
            try
                state_plus = SIR(z.t, state.s, state.i, state.r)
                violation = evolution_history(state_plus, chron0; conditioned=true)
                @debug println("state:     ", sprint(show, MIME("text/plain"), state))
                @debug println("chron0:    ", sprint(show, MIME("text/plain"), chron0))
                @debug println("deleted:   ", sprint(show, MIME("text/plain"), z))
                @debug println("full path: ", sprint(show, MIME("text/plain"), violation))
            catch e
                (e isa MissedCRemoval) ? nothing : rethrow()
                @debug e
            else
                @debug println("$pointer: ", sprint(show, MIME("text/plain"), z))
                throw(NonMinimalLFE(ev))
            end
        end
        if z ∈ ev.LFE
            (state, pointer) = iterate(cycle, pointer)                                              # <4>
        end
    end
    return true                                                                                     # <5>
end
# 1. We construct the `trajectory` generated by the `LFE` from the `Evolution` `ev` and use this to build an
# iterator `cycle`.
# 2. We work in order through the sorted union of the `history` and `LFE` of `ev`.
# 3. When we come across an [`OperativeInfection`](@ref) from `LFE` then we omit this to build a reduced chronology
# `chron0`. Taking the previous `state`, we updated to the time of the `OperativeInfection` and run
# `evolution` starting at this state and using `chron0`. 
# We **expect** this to raise a [`MissedCRemoval`](@ref) exception
# (because some `CRemoval` should be missed): if it raises a different exception then we `rethrow` this;
# if no exception is raised then we `throw` a [`NonMinimalLFE`](@ref) exception.
# 4. We use the iterator `cycle` to update the most recent `state` in case `z ∈ ev.LFE`. Note
# that `pointer` references the next iterate of the iterator.
# 5. If we get to the end of this function without throwing an exception which can't be dealt with,
# then the `LFE` is genuinely minimal, so `true` is returned!

"""
Use primarily to check that the `NFZ` field of a [`CEvolution`](@ref) is genuinely a 
_no-fly zone_. The function works through the
[`ExpungedInfection`](@ref)s in the `infections` field, checking that in each case if one started
from a putative success for the `ExpungedInfection` then one
would activate an conditioned `Removal`, thereby violating conditioning.
### Example
```jldoctest
infections = AIF[XI(1.5,3,4), I(2.2,2,3), XI(2.3,1,4), XI(3.1,3,4), XI(3.2,3,4), XI(3.3,3,4)]
removals   = AIR[R(3.4,4)]
cremovals  = C[C(1,1)]
chron      = sort(infections ∪ removals ∪ cremovals)
NFZ        = [-Inf, -Inf, -Inf, 3.4]
ev         = CEvolution(SIR(0,3,1,0), chron; NFZ=NFZ)
EpidemicsCFTP.is_correct_NFZ(ev)

# output
true
```
"""
function is_correct_NFZ(ev::CEvolution)::Bool
# import EpidemicsCFTP: evolution_history, EmployedRemoval, ExpungedInfection,
#                       ExpungedInfectionGivesValidTrajectory
    if all(t==-Inf for t in ev.NFZ)                                                        # <1>
        return true
    end
    expunged   = filter(z -> z isa ExpungedInfection, ev.infections)                        # <2>
    if isempty(expunged)
        return true
    end
    state_dict = Dict(zip(ev.history, ev.trajectory[2:end]))                                # <3>
    
    state      = ev.initial
    for z in sort(ev.history ∪ expunged)                                                    # <4>
        if z isa ExpungedInfection
            try
                beginning = SIR(z.t, state.n - z.infectee, z.infectee - state.r, state.r)   # <5>
                chron0 = [zz for zz in ev.chronology if zz>z]
                evolution_history(beginning, chron0, conditioned=true)
            catch e
                e isa EmployedRemoval ? nothing : rethrow()
                return true
            end
            throw(ExpungedInfectionGivesValidTrajectory(ev, z))                             # <6>
        else
            state = state_dict[z]                                                           # <7>
        end
    end
end
# 1. Return `true` if `NFZ` is filled with `-Inf`.
# 2. List the `ExpungedInfection`s in the `infections` field. Return `true` if this is empty.
# 3. Construct a dictionary mapping `history` to `trajectory[2:end]` so that each incident in
# `ev.history` is mapped to the state of the epidemic at the time of the incident.
# 4. Iterate through the ordered list of the union of `ev.history` and `ExpungedInfection`s.
# 5. For each `ExpungedInfection`, compute a trajectory based on a start in which `z` actually succeeded 
# making an infection! Catch every exception that arises, ignore `EmployedRemoval` exceptions,
# `rethrow` all others. 
# 6. If the computed trajectory doesn't return an error, then `z` should not have been expunged!
# So raise an appropriate exception, namely [`ExpungedInfectionGivesValidTrajectory`](@ref).
# 7. For incidents which are not `ExpungedInfection`s, simply update the `state`.

# Random samplers
# ---------------
"""
Enable sampling from an `InnovationStart_IS` to return an `Int` which is
the proposed new initial number of infections.
### Example
```jldoctest
import Random: seed!
seed!(9)
iv_ST = InnovationStart_IS(Real[0.4, 0.3, 0.3], 1)
println([z.proposal for z in rand(iv_ST, 4)])

# output
[1, 1, 2, 1]
```
"""
function Base.rand(rng::AbstractRNG, d::SamplerTrivial{InnovationStart_IS})::InnovationStart_IS
    return InnovationStart_IS(d[].prior, rand(rng, d[].prior))
end

"""
Enable sampling from an `InnovationStart_sRWM`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP, Distributions)
import Random: seed!
seed!(9)
iv_RWM = InnovationStart_sRWM(Real[0.4, 0.3, 0.3], 0.5, -1)
[(z.shift, z.mark) for z in rand(iv_RWM, 3)]

# output
3-element Vector{Tuple{Int64, Float64}}:
 (1, 0.32267671953844956)
 (1, 0.44225646604528)
 (-1, 0.3631773712936526)
```
"""
function Base.rand(rng::AbstractRNG, d::SamplerTrivial{InnovationStart_sRWM}):Int
    return InnovationStart_sRWM(d[].prior, rand(rng, Uniform(0,1)), rand(rng, 2*Bernoulli()-1))
end

"""
Enable sampling from an `InnovationStart_aRWM`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP, Distributions)
import Random: seed!
seed!(9)
iv_RWM = InnovationStart_aRWM(Real[0.4, 0.3, 0.3], 0.5, 0.5, -1)
[(z.shift, z.mark) for z in rand(iv_RWM, 3)]

# output
3-element Vector{Tuple{Int64, Float64}}:
 (1, 0.32267671953844956)
 (1, 0.44225646604528)
 (-1, 0.3631773712936526)
```
"""
function Base.rand(rng::AbstractRNG, d::SamplerTrivial{InnovationStart_aRWM}):Int
    return InnovationStart_aRWM(d[].prior, d[].ρ, rand(rng, Uniform(0,1)), rand(rng, 2*Bernoulli(1-d[].ρ)-1))
end


"""
Enable sampling of a new `Innovation`.
### Example 1
```jldoctest
using EpidemicsCFTP.abbreviations
import Random: seed!
seed!(9)
iv = Innovation(2, AIF[I(0.0, 1, 2)], R[], C[C(1.0, 2)], duration=2.0, size=2, α=2, β=3)
rand(iv)

# output
Innovation(2,
infections: AbstractInfection[ℐ₀.₁₃¹ᑉ²,ℐ₀.₁₄¹ᑉ²,ℐ₀.₉₂¹ᑉ²]
removals:   AbstractRemoval[ℛ₀.₀₄¹,ℛ₀.₀₈¹,ℛ₀.₁₀²,ℛ₀.₁₅²,ℛ₀.₂₁²,ℛ₀.₇₂²,ℛ₀.₇₃¹,ℛ₀.₈₈¹,ℛ₁.₃₄²,
    ℛ₁.₃₅²,ℛ₁.₄₈²,ℛ₁.₆₃²,ℛ₁.₈₁²,ℛ₁.₉₅¹]
cremovals:  CRemoval[𝒞₁.₀₀¹])
```
### Example 2
```jldoctest
using EpidemicsCFTP.abbreviations
import Random: seed!
seed!(9)
iv = Innovation(2, AIF[I(0.0, 1, 2)], R[], C[C(1.0, 2)], duration=2.0, size=2, α=-2, β=3)
rand(iv)

# output
ERROR: Infection or removal parameter for innovation is not positive!
```
"""
function Base.rand(rng::AbstractRNG, d::SamplerTrivial{Innovation})::Innovation
    iv = d[]
    n = iv.population  # test this?
    m = iv.size > 0 ? iv.size : n
    duration = iv.duration # test this?
    α, β = iv.α, iv.β
    if !(α > 0 && β > 0)
        error("Infection or removal parameter for innovation is not positive!")
    end
    removals = ∪([AIR[R(t, k) 
        for t ∈ rand(rng, Uniform(0, duration), rand(rng, Poisson(β * duration)))] 
        for k ∈ 1:m]...)
    infections = ∪(Vector{AIF}[[
                        I(t, rand(rng, DiscreteUniform(1, k-1)), k)
                    for t ∈ rand(rng, Uniform(0, duration), 
                        rand(rng, Poisson((k-1) * (n - k + 1) * α * duration)))] 
                    for k ∈ 2:m]...)
    if isempty(iv.cremovals)
        return typeof(iv)(n, infections, removals; duration=duration, α=α, β=β)
    else
        cremovals = C[alter(x...) 
            for x ∈ zip(iv.cremovals, 
                rand(rng, DiscreteUniform(1, m), length(iv.cremovals)))]
        return typeof(iv)(n, infections, removals, cremovals;
                            duration=duration, α=α, β=β)
    end    
end
