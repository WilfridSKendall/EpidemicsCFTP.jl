## Types for various incidents.
"""
    AbstractTimedOccurrence

This represents an abstract incident or a state as occurring
at a time specified by a `Real` number `t`.

Expects field `t<:Real` (used by function [`isearlier`](@ref)
to time-order lists of `AbstractTimedOccurrence` entities).
"""
abstract type AbstractTimedOccurrence end

"""
    AbstractIncident

Sub-type of [`AbstractTimedOccurrence`](@ref).

Expects field `kind<:String` (used by function `show`
to represent the particular kind of incident).
"""
abstract type AbstractIncident <: AbstractTimedOccurrence end

## AbstractIncidents representing removals and infections and their markers

"""
    AbstractRemoval

This represents an abstract removal using a sub-type of [`AbstractIncident`](@ref).  
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects field `target<:Integer`.

If the potential removal is to become realized 
then `target` must index a time line which is infectious just before time `t`.
"""
abstract type AbstractRemoval <: AbstractIncident end

"""
    OperativeRemoval

This represents an _operative_ abstract removal using a sub-type of [`AbstractRemoval`](@ref).
It inherits from `AbstractIncident` an expectation of field `t<:Real`. 
Also expects a field `target<:Integer`.

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
Also expects a field `target<:Integer`.

The `target` field labels the timeline being considered as host for the removal incident:
it must be a positive integer.  

Such an incident will never be realized.
"""
abstract type NonOperativeRemoval <: AbstractRemoval end

"""
    AbstractInfection

This represents an abstract infection using a sub-type of [`AbstractIncident`](@ref).
Inherits expectation of field `t<:Real` from `AbstractIncident`).  
Also expects fields `target<:Integer` and `infectee<:Integer`,
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
Also expects fields `target<:Integer` and `infectee<:Integer`,
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
Also expects fields `target<:Integer` and `infectee<:Integer`,
such that `target < infectee`.

Such an incident will never be realized.
"""
abstract type NonOperativeInfection <: AbstractInfection end


## Various kinds of removal

"""
    Removal(t::Real, target::Integer)

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
    target    ::Int64

    function Removal(t::Real, target::Integer)
        noun = "Removal($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("ℛ", t, target))
    end
end


"""
    CRemoval(t::Real, target::Integer)

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
    target    ::Int64

    function CRemoval(t::Real, target::Integer)
        noun = "CRemoval($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("𝒞", t, target))
    end

    function CRemoval(z::OperativeRemoval)
        CRemoval(z.t, z.target)
    end
end


"""
    KilledRemoval(t::Real, target::Integer)

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
    target    ::Int64

    function KilledRemoval(t::Real, target::Integer)
        noun = "KilledRemoval($t, $target)"
        (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("𝒦", t, target))
    end

    function KilledRemoval(z::AbstractRemoval)
        KilledRemoval(z.t, z.target)
    end
end

## Various kinds of infection

"""
    Infection(t::Real, infectee::Integer, target::Integer)

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
    target    ::Int64
    infectee  ::Int64

    function Infection(t::Real, target::Int, infectee::Int)
        noun = "Infection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark(s)"))
        else
            new("ℐ", t, target, infectee)
        end
    end
end

"""
    PInfection(t::Real, infectee::Integer, target::Integer)

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
    target    ::Int64
    infectee  ::Int64
    
    function PInfection(t::Real, target::Integer, infectee::Integer)
        noun = "PInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒫", t, target, infectee)
        end
    end
    
    function PInfection(z::AbstractInfection)
        PInfection(z.t, z.target, z.infectee)
    end
end

"""
    NoFlyInfection(t::Real, infectee::Integer, target::Integer)

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
    target    ::Int64
    infectee  ::Int64
    
    function NoFlyInfection(t, target, infectee)
        noun = "NoFlyInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒩", t, target, infectee)
        end
    end
    
    function NoFlyInfection(z::AbstractInfection)
        NoFlyInfection(z.t, z.target, z.infectee)
    end
end

"""
    KilledInfection(t::Real, infectee::Integer, target::Integer)

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
    target    ::Int64
    infectee  ::Int64
    
    function KilledInfection(t::Real, target::Integer, infectee::Integer)
        noun = "KilledInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒦", t, target, infectee)
        end
    end
    
    function KilledInfection(z::AbstractInfection)
        KilledInfection(z.t, z.target, z.infectee)
    end
end



"""
    CancelledInfection(t::Real, infectee::Integer, target::Integer)

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
    target    ::Int64
    infectee  ::Int64
    
    function CancelledInfection(t, target, infectee)
        noun = "CancelledInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            new("𝒳", t, target, infectee)
        end
    end
    
    function CancelledInfection(z::AbstractInfection)
        CancelledInfection(z.t, z.target, z.infectee)
    end
end

## Environments and trajectories

"""
    AbstractEnvironment

Represents variants of an entire innovation of environment 
for a single step of algorithmic time.

Instances should always possess the following fields: 

| Field name   | Type                         | Further remarks               |
|:-------------|:-----------------------------|:------------------------------|
| `population` | `Integer`                    | positive`Integer`             |
| `infections` | `Vector{AbstractInfection}`  | time-ordered list             |
| `removals`   | `Vector{AbstractRemoval}`    | time-ordered list             |
| `cremovals`  | `Vector{CRemoval}`           | time-ordered list if nonempty |
"""
abstract type AbstractEnvironment end

"""
    Innovation(population::Integer, infections::Vector{S},
               removals::Vector{T},
               cremovals::Vector{CRemoval}) where {S<:AbstractInfection, T<:AbstractRemoval}

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

    function Innovation(population::Integer, infections::Vector{S},
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

    function Innovation(population::Integer, infections::Vector{S},
                        removals::Vector{T}) where {S<:AbstractInfection, T<:AbstractRemoval}
        Innovation(population, infections, removals, CRemoval[])
    end
    
end


## An `SIR` state for an $\SIR$ epidemic and associated functions
"""
    SIR(t::Real, s::Integer, i::Integer, r::Integer)

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

    function SIR(t, s, i, r, n)
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

    function SIR(t, s, i, r)
        n = s + i + r

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
        
        new(t, s, i, r, n)
    end

end

## Structures capturing $SIR$ epidemics

"""
    AbstractEvolution 

This represents variants of evolution of an `S-I-R` epidemic.
It is a generic sub-type of [AbstractEnvironment](@ref)

Instances should always possess fields as follows:

| Field name   | Type                         |                                |
|:-------------|:-----------------------------|:-------------------------------|
| `infections` | `Vector{AbstractInfection}`  | time-ordered list              |
| `removals`   | `Vector{AbstractRemoval}`    | time-ordered list              |
| `cremovals`  | `Vector{CRemoval}`           | time-ordered list if nonempty  |
| `chronology` | `Vector{AbstractIncident}`   | **computed** time-ordered list |
| `trajectory` | `Vector{SIR}`                | **computed** time-ordered list |
| `history`    | `Vector{AbstractIncident}`   | **computed** time-ordered list |
"""
abstract type AbstractEvolution <: AbstractEnvironment end

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

"""
    Evolution(initial_state::SIR, innovation::Innovation)

This implements _unconditional_ evolution of an SIR epidemic 
based on a given [`Innovation`](@ref) 
for innovations,
and starting from a given [`SIR`](@ref) for initial state.

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals)
and also computed fields `chronology`, `trajectory` and `history`.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial    = SIR(0.0, 2, 1, 0)
SIR₀.₀₀(2:1:0)
julia> population = initial.n
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)]
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.2, 3), Removal(0.1, 2)]
Removal[ℛ₀.₂₀³,ℛ₀.₁₀²]
julia> cremovals  = [CRemoval(0.0, 1), CRemoval(0.05, 2)]
CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
julia> innov      = Innovation(population, infections, removals, cremovals)
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
)
julia> Evolution(initial, innov)
Evolution(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
chronology: AbstractIncident[𝒞₀.₀₀¹,𝒞₀.₀₅²,ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹]
)
```
"""
struct Evolution <: AbstractEvolution
    population ::Int
    infections ::Vector{<:AbstractInfection}
    removals   ::Vector{<:AbstractRemoval}
    cremovals  ::Vector{CRemoval}
    chronology ::Vector{<:AbstractIncident}
    trajectory ::Vector{SIR}
    history    ::Vector{AbstractIncident}
    
    function Evolution(initial_state::SIR, innovation::Innovation)
        # Need to check population == sum of initial.state entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation)
        new(population, infections, removals, cremovals, chronology, trajectory, history)
    end
end

"""
    CEvolution(initial_state::SIR, innovation::Innovation)

This implements _conditional_ evolution of an SIR epidemic 
based on a given [`Innovation`](@ref) 
for innovations,
and starting from a given [`SIR`](@ref) for initial state.
An error is raised if the resulting `evolution` activates
an [`AbstractRemoval](@ref) incident which is not a [`CRemoval`](@ref).

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals)
and also computed fields `chronology`, `trajectory` and `history`.

## Example
Three cases: straightforward, missing a conditioned removal, employing an (unconditioned) removal:
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial    = SIR(0.0, 2, 1, 0)
SIR₀.₀₀(2:1:0)
julia> population = initial.n
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)]
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.2, 3), Removal(0.1, 2)]
Removal[ℛ₀.₂₀³,ℛ₀.₁₀²]
julia> cremovals  = [CRemoval(0.0, 1)]
CRemoval[𝒞₀.₀₀¹]
julia> innov      = Innovation(population, infections, removals, cremovals) 
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹]
)
julia> CEvolution(SIR(0.0, 2, 1, 0), innov)
CEvolution(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹]
chronology: AbstractIncident[𝒞₀.₀₀¹,ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹]
)

julia> cremovals  = [CRemoval(0.0, 2)] ;

julia> innov      = Innovation(population, infections, removals, cremovals) ;

julia> CEvolution(initial, innov)
ERROR: [MissedCRemoval] The (conditioned) evolution misused CRemoval(0.0, 2)

julia> removals   = [Removal(0.1, 1), Removal(0.1, 2)] ;

julia> cremovals  = [CRemoval(0.2, 1)] ;

julia> innov      = Innovation(population, infections, removals, cremovals) ;

julia> CEvolution(initial, innov)
ERROR: [EmployedRemoval] The (conditioned) evolution misused Removal(0.1, 1)
```
"""
struct CEvolution <: AbstractEvolution
    population ::Int
    infections ::Vector{<:AbstractInfection}
    removals   ::Vector{<:AbstractRemoval}
    cremovals  ::Vector{CRemoval}
    chronology ::Vector{<:AbstractIncident}
    trajectory ::Vector{SIR}
    history    ::Vector{AbstractIncident}
    
    function CEvolution(initial_state::SIR, innovation::Innovation)
        # Need to check population == sum of `initial_state` entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation, conditioned=true)
        new(population, infections, removals, cremovals, chronology, trajectory, history)
    end
end
