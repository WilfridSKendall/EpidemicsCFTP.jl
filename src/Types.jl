# Types for various incidents
# -------------------------------

# Abstract occurrence
# -------------------------------
"""
    AbstractTimedOccurrence

This represents an abstract incident or a state as occurring
at a time specified by a `Real` number `t`.

# Expects field `t<:Real` (used by function [`isearlier`](@ref)
to time-order lists of `AbstractTimedOccurrence` entities).
"""
abstract type AbstractTimedOccurrence end

# Abstract incident
# -------------------------------
"""
    AbstractIncident

Sub-type of [`AbstractTimedOccurrence`](@ref).

Expects field `kind<:String` (used by function `show`
to represent the particular kind of incident).
"""
abstract type AbstractIncident <: AbstractTimedOccurrence end

# AbstractIncidents representing removals
# -------------------------------
"""
    AbstractRemoval

This represents an abstract removal using a sub-type of [`AbstractIncident`](@ref).  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects field `target<:Int`.

If the potential removal is to become realized 
then `target` must index a time line which is infectious just before time `t`.
"""
abstract type AbstractRemoval <: AbstractIncident end

"""
    OperativeRemoval

This represents an _operative_ abstract removal using a sub-type of [`AbstractRemoval`](@ref).
It inherits from `AbstractIncident` an expectation of field `t<:Real`. 
Also expects a field `target<:Int`.

The `target` field labels the timeline being considered as host for the removal incident:
it must be a positive integer.  

The `OperativeRemoval` is realized if the specified timeline is infectious just before time `t`.
If the potential removal is to become realized 
then `target` must index a time line which is infectious just before the removal.
"""
abstract type OperativeRemoval <: AbstractRemoval end

"""
    NonOperativeRemoval

This represents a _nonoperative_ abstract removal using a sub-type of [`AbstractRemoval`](@ref).
It inherits from `AbstractIncident` an expectation of field `t<:Real`. 
Also expects a field `target<:Int`.

The `target` field labels the timeline being considered as host for the removal incident:
it must be a positive integer.  

Such an incident will never be realized.
"""
abstract type NonOperativeRemoval <: AbstractRemoval end

# AbstractIncidents representing infections
# -------------------------------
"""
    AbstractInfection

This represents an abstract infection using a sub-type of [`AbstractIncident`](@ref).
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects fields `target<:Int` and `infectee<:Int`,
such that `target < infectee`.

Under conditioning on removals,
we distinguish between `AbstractInfection` instances which _may_ be
activated (`OperativeInfection`) and those which should not _ever_ be
activated (`NonoOperativeInfection`), because their targets are
on "removed" portions of time lines or because they would if activated
lead to removal of inactivated `Removal` incidents.
"""
abstract type AbstractInfection <: AbstractIncident end

"""
    OperativeInfection

This represents an _operative_ abstract infection using a sub-type of [`AbstractInfection`](@ref).
It inherits from [`AbstractIncident`](@ref) an expectation of field `t<:Real`. 
Also expects fields `target<:Int` and `infectee<:Int`,
such that `target < infectee`.

If the potential infection is to become realized 
then `target` must index a time line which is infectious, 
and `infectee` must index the susceptible time line of smallest
index, both measured just before time `t`.

In particular, if there is no timeline which is susceptible
just before time `t` then the infection cannot be realized
whatever the value of `target`.
"""
abstract type OperativeInfection <: AbstractInfection end

"""
    NonOperativeInfection

This represents a _non-operative_ abstract infection using a sub-type of [`AbstractInfection`](@ref).
It inherits from [`AbstractIncident`](@ref) an expectation of field `t<:Real`.  
Also expects fields `target<:Int` and `infectee<:Int`,
such that `target < infectee`.

Such an incident will never be realized.
"""
abstract type NonOperativeInfection <: AbstractInfection end


# Actual removals
# -------------------------------
"""
    Removal(::Float64, ::Int)

Implements a potential removal using a sub-type of [`OperativeRemoval`](@ref).  
The `target` field labels the timeline being considered as host for the removal incident: it must be a positive integer.  
The `Removal` is realized if the specified timeline is infectious just before time `t`.

If activated in course of evolution of a conditioned epidemic then an error will be raised.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Removal(0.1, 4)
ℛ₀.₁₀⁴
```
"""
struct Removal <: OperativeRemoval
    kind      ::String     
    t         ::Float64
    target    ::Int

    function Removal(t::T, target::Int) where T <: Union{Float64, Int}
        noun = "Removal($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("ℛ", float(t), target))
    end

    function Removal(z::AbstractRemoval)
        Removal(z.t, z.target)
    end
end


"""
    CRemoval(::Float64, ::Int)

Represent a conditioned removal using a sub-type of [`OperativeRemoval`](@ref), similar to `Removal`.
The `target` field should always index a time line which is currently infectious 
(a deterministic constraint, since the epidemic is conditional on observation of the times of all removals).

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> CRemoval(0.1, 4)
𝒞₀.₁₀⁴
julia> z = Removal(0.1, 4) ;

julia> CRemoval(z)
𝒞₀.₁₀⁴
```
"""
struct CRemoval <: OperativeRemoval
    kind      ::String     
    t         ::Float64
    target    ::Int

    function CRemoval(t::T, target::Int) where T <: Union{Float64, Int}
        noun = "CRemoval($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("𝒞", float(t), target))
    end

    function CRemoval(z::AbstractRemoval)
        CRemoval(z.t, z.target)
    end
end


"""
    KilledRemoval(::Float64, ::Int)

Implements a removal which can never be activated using a sub-type of [`AbstractRemoval`](@ref).  
The `target` field labels the timeline being considered as host for the removal incident: it must be a positive integer.  
The `KilledRemoval` is never realized.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> KilledRemoval(0.1, 4)
𝒦₀.₁₀⁴
julia> z = Removal(0.1, 4) ;

julia> KilledRemoval(z)
𝒦₀.₁₀⁴
```
"""
struct KilledRemoval <: NonOperativeRemoval
    kind      ::String     
    t         ::Float64
    target    ::Int

    function KilledRemoval(t::T, target::Int) where T <: Union{Float64, Int}
        noun = "KilledRemoval($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("𝒦", float(t), target))
    end

    function KilledRemoval(z::AbstractRemoval)
        KilledRemoval(z.t, z.target)
    end
end

# Actual infections
# -------------------------------
"""
    Infection(::Float64, ::Int, ::Int)
    
Represent a potential infection using a sub-type of [`OperativeInfection`](@ref),
using mark time `t` and another mark `target` and a further mark `infectee`.
Marks `target` and `infectee` must be positive integers with `target < infectee`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Infection(0.2, 1, 2)
ℐ₀.₂₀¹⁻²
```
"""
struct Infection <: OperativeInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int

    function Infection(t::T, target::Int, infectee::Int) where T <: Union{Float64, Int}
        noun = "Infection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark(s)"))
        else
            new("ℐ", float(t), target, infectee)
        end
    end

    function Infection(z::AbstractInfection)
        Infection(z.t, z.target, z.infectee)
    end
end

"""
    PInfection(::Float64, ::Int, ::Int)

Represent a perpetuated infection using a sub-type of [`OperativeInfection`](@ref)
which is identical to `Infection` but with a different name.
Intended to identify an `Infection` from a previous iteration of the CFTP
algorithm which has had to be carried over to avoid failure to activate
a `CRemoval`.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> PInfection(0.2, 1, 2)
𝒫₀.₂₀¹⁻²
julia> z = Infection(0.2, 1, 2) ;

julia> PInfection(z)
𝒫₀.₂₀¹⁻²
```
"""
struct PInfection <: OperativeInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function PInfection(t::T, target::Int, infectee::Int) where T <: Union{Float64, Int}
        noun = "PInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒫", float(t), target, infectee)
        end
    end
    
    function PInfection(z::AbstractInfection)
        PInfection(z.t, z.target, z.infectee)
    end
end

"""
    NoFlyInfection(::Float64, ::Int, ::Int)

Represent an infection using a sub-type of [`NonOperativeInfection`](@ref)
which is otherwise identical to `Infection` but with a different name.
Intended to identify an `Infection` whose time line is not infected
and whose activation would lead to activation of an otherwise inactive
`Removal`.

It is however operative: if it is activated in the course of the evolution
of a conditioned epidemic then it will lead to an error
when subsequently a `Removal` becomes activated.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> NoFlyInfection(0.2, 1, 2)
𝒩₀.₂₀¹⁻²
julia> z = Infection(0.2, 1, 2) ;

julia> NoFlyInfection(z)
𝒩₀.₂₀¹⁻²
```
"""
struct NoFlyInfection <: OperativeInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function NoFlyInfection(t::T, target::Int, infectee::Int) where T <: Union{Float64, Int}
        noun = "NoFlyInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒩", float(t), target, infectee)
        end
    end
    
    function NoFlyInfection(z::AbstractInfection)
        NoFlyInfection(z.t, z.target, z.infectee)
    end
end

"""
    KilledInfection(::Float64, ::Int, ::Int)

Represent an infection using a sub-type of [`NonOperativeInfection`](@ref)
which is otherwise identical to `Infection` but with a different name.
Intended to identify an `Infection` which cannot be activated because
its time line is not infected.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> KilledInfection(0.2, 1, 2)
𝒦₀.₂₀¹⁻²
julia> z = Infection(0.2, 1, 2) ;

julia> KilledInfection(z)
𝒦₀.₂₀¹⁻²
```
"""
struct KilledInfection <: NonOperativeInfection

    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function KilledInfection(t::T, target::Int, infectee::Int) where T <: Union{Float64, Int}
        noun = "KilledInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒦", float(t), target, infectee)
        end
    end
    
    function KilledInfection(z::AbstractInfection)
        KilledInfection(z.t, z.target, z.infectee)
    end
end



"""
    CancelledInfection(::Float64, ::Int, ::Int)

Represent an infection using a sub-type of [`OperativeInfection`](@ref)
which is otherwise identical to `Infection` but with a different name.
Intended to identify an `Infection` which can in principle be made active,
but if so then it would lead to activation of an otherwise inactive
`Removal`.

If such an incident is activated then it will in due course lead
to an error being raised when a [`Removal`](@ref) 
(as opposed to a [`CRemoval`](@ref)) is activated.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> CancelledInfection(0.2, 1, 2)
𝒳₀.₂₀¹⁻²
julia> z = Infection(0.2, 1, 2) ;

julia> CancelledInfection(z)
𝒳₀.₂₀¹⁻²
```
"""
struct CancelledInfection <: NonOperativeInfection

    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function CancelledInfection(t::T, target::Int, infectee::Int) where T <: Union{Float64, Int}
        noun = "CancelledInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒳", float(t), target, infectee)
        end
    end
    
    function CancelledInfection(z::AbstractInfection)
        CancelledInfection(z.t, z.target, z.infectee)
    end
end

# Environments
# -------------------------------
"""
    AbstractEnvironment

Represents variants of an entire innovation of environment 
for a single step of algorithmic time.

Instances should always possess the following fields: 

| Field name   | Type                         | Further remarks               |
|:-------------|:-----------------------------|:------------------------------|
| `population` | `Int`                    | positive`Int`             |
| `infections` | `Vector{AbstractInfection}`  | time-ordered list             |
| `removals`   | `Vector{AbstractRemoval}`    | time-ordered list             |
| `cremovals`  | `Vector{CRemoval}`           | time-ordered list if nonempty |
"""
abstract type AbstractEnvironment end

# Innovations
# -------------------------------
"""
    Innovation(::Int, ::Vector{S}, ::Vector{T},
               ::Vector{CRemoval}) where {S<:AbstractInfection, T<:AbstractRemoval}

This represents an entire innovation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals).

Note that there is a computed field `chronology` holding a
time-ordered list of the incidents in `infections`, `removals`, and `cremovals`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> population = 3
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)]
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.2, 3), Removal(0.1, 2)]
Removal[ℛ₀.₂₀³,ℛ₀.₁₀²]
julia> cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 2)]
CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
julia> Innovation(population, infections, removals, cremovals)
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
)
```
"""
struct Innovation <: AbstractEnvironment
    population ::Int
    infections ::Vector{<:AbstractInfection}
    removals   ::Vector{<:AbstractRemoval}
    cremovals  ::Vector{CRemoval}
    chronology ::Vector{<:AbstractIncident}

    function Innovation(population::Int, infections::Vector{S},
                        removals::Vector{T},
                        cremovals::Vector{CRemoval}) where {S<:AbstractInfection, T<:AbstractRemoval}
        noun = "Innovation($population, $infections, $removals, $cremovals)"
        if population ≤ 0
            throw(DomainError(noun, "non-positive population size $population"))
        elseif length(cremovals) > population
            throw(ArgumentError("too many conditional removals in \n$noun"))
        elseif any(cr.target > population for cr in cremovals)
            throw(ArgumentError("some conditional removal timelines too high in \n$noun"))
        elseif any(r.target > population for r in removals)
            throw(ArgumentError("some removal timelines too high in \n$noun"))
        elseif any(i.target > population for i in infections)
            throw(ArgumentError("some infection targets too high in \n$noun"))
        else
            chron = Iterators.flatten([infections, removals, cremovals])
            new(population, sort(infections, lt=isearlier), 
                sort(removals,   lt=isearlier), 
                sort(cremovals,  lt=isearlier),
                [x::AbstractIncident for x in sort(collect(chron), lt=isearlier)])
        end
    end

    function Innovation(population::Int, infections::Vector{S},
                        removals::Vector{T}) where {S<:AbstractInfection, T<:AbstractRemoval}
        Innovation(population, infections, removals, CRemoval[])
    end
    
end


# An `SIR` state for an $\SIR$ epidemic and associated functions
# -------------------------------
"""
    SIR(::Float64, ::Int, ::Int, ::Int)

This represents a state of a `S-I-R` epidemic (`s`, `i`, `r`)
(all non-negative integers adding up to a positive integer `n`
which is the population size, given by the computed field `population`)
at a specified time `t` (a real number). Note that `n` is computed
at initialization of the state structure and accessed as `sir.n`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> sir = SIR(0.1, 1, 2, 3)
SIR₀.₁₀(1:2:3)

julia> sir.n
6

julia> sir == SIR(0.1, 1, 2, 3, 6)
true
```
"""
struct SIR <: AbstractTimedOccurrence
    t::Float64
    s::Int
    i::Int
    r::Int
    n::Int

    function SIR(t::Float64, s::Int, i::Int, r::Int, n::Int)
        noun = "SIR($t, $s, $i, $r, $n)"
        if s < 0
            throw(DomainError(noun, "negative number $s of susceptibles"))
        elseif i < 0
            throw(DomainError(noun, "negative number $i of infectives"))
        elseif r < 0
            throw(DomainError(noun, "negative number $r of removals"))
        elseif s + i + r == 0
            throw(DomainError(noun, "zero total computed population"))
        elseif s + i + r != n
            throw(DomainError(noun, "population n=$n is not sum of s=$s, i=$i, r=$r"))
        end
        
        new(t, s, i, r, n)
    end

    function SIR(t::Float64, s::Int, i::Int, r::Int)
        noun = "SIR($t, $s, $i, $r)"
        if s < 0
            throw(DomainError(noun, "negative number $s of susceptibles"))
        elseif i < 0
            throw(DomainError(noun, "negative number $i of infectives"))
        elseif r < 0
            throw(DomainError(noun, "negative number $r of removals"))
        elseif s + i + r == 0
            throw(DomainError(noun, "zero total computed population"))
        end
        new(t, s, i, r, s + i + r)
    end

end

## Structures for $\text{S-I-R}$ epidemics
# -------------------------------


"""
    AbstractEvolution 

This represents variants of evolution of an `S-I-R` epidemic.
It is a generic sub-type of [`AbstractEnvironment`](@ref)

Instances should always possess fields as follows:

| Field name    | Type                         |              |                   |
|:--------------|:-----------------------------|:-------------|-------------------|
| `infections`  | `Vector{AbstractInfection}`  |              | time-ordered list |
| `removals`    | `Vector{AbstractRemoval}`    |              | time-ordered list |
| `cremovals`   | `Vector{CRemoval}`           |              | time-ordered list |
| `chronology`  | `Vector{AbstractIncident}`   | **computed** | time-ordered list |
| `trajectory`  | `Vector{SIR}`                | **computed** | time-ordered list |
| `history`     | `Vector{AbstractIncident}`   | **computed** | time-ordered list |
| `start_times` | `Vector{Real}`               | **computed** | list              |
| `finis_times` | `Vector{Real}`               | **computed** | list              |
"""
abstract type AbstractEvolution <: AbstractEnvironment end

"""
    Evolution(::SIR, ::Innovation)

This implements _unconditional_ evolution of an SIR epidemic 
based on a given [`Innovation`](@ref) 
for innovations,
and starting from a given [`SIR`](@ref) for initial state.

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals)
and also computed fields `chronology`, `trajectory` and `history`.

Note the implicit use of [`evolution`](@ref) (with the `conditioned` flag at default of `false`)
to compute the `trajectory` and `history` fields
and the implicit use of [`EpidemicsCFTP.periods`](@ref) to compute start and finish times
for infectious periods!
## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial    = SIR(0.0, 2, 1, 0)
SIR₀.₀₀(2:1:0)
julia> population = initial.n
3
julia> infections = [NoFlyInfection(0.7,1,2), PInfection(0.5,1,2)]
OperativeInfection[𝒩₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.2, 3), Removal(0.1, 2)]
Removal[ℛ₀.₂₀³,ℛ₀.₁₀²]
julia> cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 2)]
CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
julia> innov      = Innovation(population, infections, removals, cremovals)
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
)
julia> ev = Evolution(initial, innov)
Evolution(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
chronology: AbstractIncident[𝒞₀.₀₀¹,𝒞₀.₀₅²,ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹]
)
julia> println(ev.start_times)
Real[0.0, Inf, Inf]
julia> println(ev.finis_times)
Real[0.0, Inf, Inf]
```
"""
struct Evolution <: AbstractEvolution
    population  ::Int
    infections  ::Vector{<:AbstractInfection}
    removals    ::Vector{<:AbstractRemoval}
    cremovals   ::Vector{CRemoval}
    chronology  ::Vector{<:AbstractIncident}
    trajectory  ::Vector{SIR}
    history     ::Vector{AbstractIncident}
    start_times ::Vector{Real}
    finis_times ::Vector{Real}
    
    function Evolution(initial_state::SIR, innovation::Innovation)
        # Need to check population == sum of initial.state entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation)
        start_times, finis_times = periods(trajectory, history)
        new(population, infections, removals, cremovals, chronology, 
            trajectory, history, start_times, finis_times)
    end
end

"""
    CEvolution(::SIR, ::Innovation)

This implements _conditional_ evolution of an SIR epidemic 
based on a given [`Innovation`](@ref) 
for innovations,
and starting from a given [`SIR`](@ref) for initial state.
An error is raised if the resulting `evolution` activates
an [`AbstractRemoval`](@ref) incident which is not a [`CRemoval`](@ref).

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals)
and also computed fields `chronology`, `trajectory` and `history`.
Note the implicit use of [`evolution`](@ref) (with the `conditioned` flag set to `true`)
to compute the `trajectory` and `history` fields,
and the implicit use of [`EpidemicsCFTP.periods`](@ref) to compute start and finish times
for infectious periods!

## Example
Three cases: basic use, missing a conditioned removal, employing an (unconditioned) removal.
Notice that we introduce some non-standard removals and infections in the "basic use" case!

I: Basic use
```jldoctest CEvolution; setup = :(using EpidemicsCFTP)
julia> initial    = SIR(0.0, 2, 1, 0)
SIR₀.₀₀(2:1:0)
julia> population = initial.n
3
julia> infections = [NoFlyInfection(0,2,3), CancelledInfection(0.2, 2, 3), Infection(0.7,1,2), PInfection(0.5,1,2)]
AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.1, 1), KilledRemoval(0.2, 3), Removal(0.1, 2)]
AbstractRemoval[ℛ₀.₁₀¹,𝒦₀.₂₀³,ℛ₀.₁₀²]
julia> cremovals  = [CRemoval(0.0, 1)]
CRemoval[𝒞₀.₀₀¹]

julia> innov      = Innovation(population, infections, removals, cremovals) 
Innovation(3,
infections: AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒦₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹]
)

julia> CEvolution(SIR(0.0, 2, 1, 0), innov)
CEvolution(3,
infections: AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒦₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹]
chronology: AbstractIncident[𝒩₀.₀₀²⁻³,𝒞₀.₀₀¹,ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒳₀.₂₀²⁻³,𝒦₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹]
)
```

II: Missing a conditioned removal
```jldoctest CEvolution
julia> cremovals  = [CRemoval(0.0, 2)]
CRemoval[𝒞₀.₀₀²]
julia> innov      = Innovation(population, infections, removals, cremovals) ;

julia> CEvolution(initial, innov)
ERROR: [MissedCRemoval] The (conditioned) evolution misused CRemoval(0.0, 2)
```

III: employing an (unconditioned) removal
```jldoctest CEvolution
julia> removals   = [Removal(0.1, 1), Removal(0.1, 2)] ;

julia> cremovals  = [CRemoval(0.2, 1)] ;

julia> innov      = Innovation(population, infections, removals, cremovals) ;

julia> CEvolution(initial, innov)
ERROR: [EmployedRemoval] The (conditioned) evolution misused Removal(0.1, 1)
```

"""
struct CEvolution <: AbstractEvolution
    population  ::Int
    infections  ::Vector{<:AbstractInfection}
    removals    ::Vector{<:AbstractRemoval}
    cremovals   ::Vector{CRemoval}
    chronology  ::Vector{<:AbstractIncident}
    trajectory  ::Vector{SIR}
    history     ::Vector{AbstractIncident}
    start_times ::Vector{Real}
    finis_times ::Vector{Real}
    
    function CEvolution(initial_state::SIR, innovation::Innovation)
        # Need to check population == sum of `initial_state` entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation, conditioned=true)
        start_times, finis_times = periods(trajectory, history)
        new(population, infections, removals, cremovals, chronology, 
            trajectory, history, start_times, finis_times)
    end
end

# Exceptions
# -------------------------------
"""
    BadIncident

An exception to report misuse of an incident. Doctests are supplied below for 
specific sub-types.
"""
abstract type BadIncident <: Exception end
        
"""
    MissedCRemoval

This is an exception raised when a [`CRemoval`](@ref) is missed by
`evolution`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
population = 3 ;
infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;
removals   = [Removal(0.2, 3), Removal(0.1, 2)] ;
cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 3)] ;
innov      = Innovation(population, infections, removals, cremovals) ;
initial    = SIR(0.0, 2, 1, 0)
CEvolution(initial, innov)

# output
ERROR: [MissedCRemoval] The (conditioned) evolution misused CRemoval(0.05, 3)
```
"""
struct MissedCRemoval <: BadIncident
    incident ::AbstractIncident
end


"""
    EmployedRemoval

This is an exception raised when a [`Removal`](@ref) is not missed by
`evolution`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
population = 3 ;
infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] ;
removals   = [Removal(0.05, 3), Removal(0.2, 1), Removal(0.1, 2)] ;
cremovals  = [CRemoval(0.5, 1)] ;
innov      = Innovation(population, infections, removals, cremovals) ;
initial    = SIR(0.0, 2, 1, 0)
CEvolution(initial, innov)

# output
ERROR: [EmployedRemoval] The (conditioned) evolution misused Removal(0.2, 1)
```
"""
struct EmployedRemoval <: BadIncident
    incident ::AbstractIncident
end
