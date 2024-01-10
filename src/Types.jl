# Types for various incidents
# -------------------------------

# Abstract occurrence
# -------------------------------
"""
    AbstractTimedOccurrence

This represents an abstract incident or a state as occurring
at a time specified by a `Real` number `t`.
Concrete sub-types are expected to possess a field `t<:Real` (used by function [`isless`](@ref)
to produce a preliminary time-ordering of lists of `AbstractTimedOccurrence` entities).
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
        return (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("ℛ", float(t), target))
    end

    function Removal(z::AbstractRemoval)
        return Removal(z.t, z.target)
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
        return (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("𝒞", float(t), target))
    end

    function CRemoval(z::AbstractRemoval)
        return CRemoval(z.t, z.target)
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
        return (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("𝒦", float(t), target))
    end

    function KilledRemoval(z::AbstractRemoval)
        return KilledRemoval(z.t, z.target)
    end
end

"""
    RemovalMarker(::Float64, ::Int)

This is a marker normally placed at the end of an epidemic to signal completion of infected time lines.

"""
struct RemovalMarker <: NonOperativeRemoval
    kind      ::String
    t         ::Float64
    target    ::Int
    
    function RemovalMarker(t::T, target::Int) where T <: Union{Float64, Int}
        noun = "RemovalMarker($t, $target)"
        return (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("ℳ⁺", float(t), target))
    end
    
    function RemovalMarker(z::AbstractRemoval)
        return RemovalMarker(z.t, z.target)
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
            return new("𝒫", float(t), target, infectee)
        end
    end
    
    function PInfection(z::AbstractInfection)
        return PInfection(z.t, z.target, z.infectee)
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
            return new("𝒩", float(t), target, infectee)
        end
    end
    
    function NoFlyInfection(z::AbstractInfection)
        return NoFlyInfection(z.t, z.target, z.infectee)
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
            return new("𝒦", float(t), target, infectee)
        end
    end
    
    function KilledInfection(z::AbstractInfection)
        return KilledInfection(z.t, z.target, z.infectee)
    end
end



"""
    ExpungedInfection(::Float64, ::Int, ::Int)

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
julia> ExpungedInfection(0.2, 1, 2)
𝒳₀.₂₀¹⁻²
julia> z = Infection(0.2, 1, 2) ;

julia> ExpungedInfection(z)
𝒳₀.₂₀¹⁻²
```
"""
struct ExpungedInfection <: NonOperativeInfection

    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function ExpungedInfection(t::T, target::Int, infectee::Int) where T <: Union{Float64, Int}
        noun = "ExpungedInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            return new("𝒳", float(t), target, infectee)
        end
    end
    
    function ExpungedInfection(z::AbstractInfection)
        return ExpungedInfection(z.t, z.target, z.infectee)
    end
end

"""
    InfectionMarker(::Float64, ::Int, ::Int)

This is a marker normally placed at the start of an epidemic to signal initial infected time lines.
Differs from (for example) `Infection` in that the `target` mark can be zero.

"""
struct InfectionMarker <: NonOperativeInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function InfectionMarker(t::T, target::Int, infectee::Int) where T <: Union{Float64, Int}
        noun = "InfectionMarker($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target < 0
            throw(DomainError(noun, "negative mark"))
        else
            return new("ℳ⁻", float(t), target, infectee)
        end
    end
    
    function InfectionMarker(z::AbstractInfection)
        return InfectionMarker(z.t, z.target, z.infectee)
    end
end

# Structures for $\text{S-I-R}$ epidemics
# -------------------------------

# ### An `SIR` state for an $\SIR$ epidemic
"""
    SIR(::Real, ::Int, ::Int, ::Int)

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

    function SIR(t::Real, s::Int, i::Int, r::Int, n::Int)
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
        
        return new(t, s, i, r, n)
    end

    function SIR(t::Real, s::Int, i::Int, r::Int)
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
        return new(t, s, i, r, s + i + r)
    end

end

# ### Abstract environment for an $\SIR$ epidemic
"""
    AbstractEnvironment

Represents variants of an entire innovation of environment 
for a single step of algorithmic time.
"""
abstract type AbstractEnvironment end

# ### Innovations
"""
    Innovation(::Int, ::Vector{S}, ::Vector{T},
               ::Vector{CRemoval}) where {S<:AbstractInfection, T<:AbstractRemoval}

This represents an entire innovation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals).

Note that there is a first argument `population` (an `Int`),
and a computed field `chronology` holding a
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
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²])
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
        elseif any(cr.target > population for cr ∈ cremovals)
            throw(ArgumentError("some conditional removal timelines too high in \n$noun"))
        elseif any(r.target > population for r ∈ removals)
            throw(ArgumentError("some removal timelines too high in \n$noun"))
        elseif any(i.target > population for i ∈ infections)
            throw(ArgumentError("some infection targets too high in \n$noun"))
        else
            chron = Iterators.flatten([infections, removals, cremovals])
            return new(population, sort(infections), 
                sort(removals), 
                sort(cremovals),
                [x::AbstractIncident for x ∈ sort(collect(chron))])
        end
    end

    function Innovation(population::Int, infections::Vector{S},
                        removals::Vector{T}) where {S<:AbstractInfection, T<:AbstractRemoval}
        return Innovation(population, infections, removals, CRemoval[])
    end
    
end

# ### Abstract evolution for an $\SIR$ epidemic
"""
    AbstractEvolution 

This represents variants of evolution of an `S-I-R` epidemic.
It is a generic sub-type of [`AbstractEnvironment`](@ref)
"""
abstract type AbstractEvolution <: AbstractEnvironment end

# ### Instances of evolution for an $\SIR$ epidemic
"""
    Evolution(::SIR, ::Innovation)

This implements _unconditional_ evolution of an SIR epidemic 
based on a given [`Innovation`](@ref) 
for innovations,
and starting from a given [`SIR`](@ref) for initial state.

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals),
initial state `initial`,
and also computed fields `chronology`, `trajectory` and `history`.

Note the implicit use of [`evolution`](@ref) (with the `conditioned` flag at default of `false`)
to compute the `trajectory` and `history` fields,
and the implicit use of [`EpidemicsCFTP.interval`](@ref) to compute start and finish incidents
for infectious intervals.
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
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²])

julia> ev = Evolution(initial, innov)
Evolution(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
chronology: AbstractIncident[𝒞₀.₀₀¹,𝒞₀.₀₅²,ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])

julia> ev = Evolution(initial, infections ∪ removals ∪ cremovals)
Evolution(3,
infections: AbstractInfection[𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
chronology: AbstractIncident[𝒞₀.₀₀¹,𝒞₀.₀₅²,ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])

julia> println(ev.start)
AbstractInfection[InfectionMarker(Inf, 0, 1), InfectionMarker(Inf, 1, 2), InfectionMarker(Inf, 2, 3)]
julia> println(ev.finis)
AbstractRemoval[CRemoval(0.0, 1), RemovalMarker(Inf, 2), RemovalMarker(Inf, 3)]
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
    initial     ::SIR
    start       ::Vector{AbstractInfection}
    finis       ::Vector{AbstractRemoval}
    #LFE         ::Vector{AbstractIncident}
    
    function Evolution(initial_state::SIR, innovation::Innovation)
        # Need to check population == sum of initial.state entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation)
        start, finis    = interval(trajectory, history)
        #LFE        = SIR[]
        return new(population, infections, removals, cremovals, chronology, 
            trajectory, history, initial_state, start, finis)
    end
    
    function Evolution(initial_state::SIR, chronology::Vector{AbstractIncident})
        innovation = Innovation(initial_state.n,
                        AbstractInfection[z for z ∈ chronology if z isa AbstractInfection],
                        AbstractRemoval[z for z ∈ chronology if z isa AbstractRemoval && !(z isa CRemoval)],
                        CRemoval[z for z ∈ chronology if z isa CRemoval],
                        )
        return Evolution(initial_state, innovation)
    end

end

"""
    CEvolution(::SIR, ::Innovation; LFE::Vector{AbstractIncident}=AbstractIncident[])

This implements _conditional_ evolution of an SIR epidemic 
based on a given [`Innovation`](@ref) 
for innovations,
and starting from a given [`SIR`](@ref) for initial state.
An error is raised if the resulting `evolution` activates
an [`AbstractRemoval`](@ref) incident which is not a [`CRemoval`](@ref).

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals),
initial state `initial`,
and also computed fields `chronology`, `trajectory` and `history`.
Note the implicit use of [`evolution`](@ref) (with the `conditioned` flag set to `true`)
to compute the `trajectory` and `history` fields,
and the implicit use of [`EpidemicsCFTP.interval`](@ref) to compute start and finish incidents
for infectious intervals.

It possesses extra fields `LFE`, `TLR` and  `envelope`, which are respectively
the incidents involved in the last feasible epidemic, the maxima _per_ time line
of times of `Removal`s occurring _before_ the epidemic trajectory as measured
by `start`, and the monotonically increasing envelope.

## Example
Three cases: basic use, missing a conditioned removal, employing an (unconditioned) removal.
Notice that we introduce some non-standard removals and infections in the "basic use" case!

I: Basic use
```jldoctest CEvolution; setup = :(using EpidemicsCFTP)
julia> initial    = SIR(0.0, 2, 1, 0)
SIR₀.₀₀(2:1:0)
julia> population = initial.n
3
julia> infections = [NoFlyInfection(0,2,3), ExpungedInfection(0.2, 2, 3), Infection(0.7,1,2), PInfection(0.5,1,2)]
AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.1, 1), KilledRemoval(0.2, 3), Removal(0.1, 2)]
AbstractRemoval[ℛ₀.₁₀¹,𝒦₀.₂₀³,ℛ₀.₁₀²]
julia> cremovals  = [CRemoval(0.0, 1)]
CRemoval[𝒞₀.₀₀¹]

julia> innov      = Innovation(population, infections, removals, cremovals) 
Innovation(3,
infections: AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒦₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹])

julia> CEvolution(initial, innov)
CEvolution(3,
infections: AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒦₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹]
chronology: AbstractIncident[𝒩₀.₀₀²⁻³,𝒞₀.₀₀¹,ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒳₀.₂₀²⁻³,𝒦₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])

julia> ev = CEvolution(initial, infections ∪ removals ∪ cremovals)
CEvolution(3,
infections: AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒦₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹]
chronology: AbstractIncident[𝒩₀.₀₀²⁻³,𝒞₀.₀₀¹,ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒳₀.₂₀²⁻³,𝒦₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])
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
    population ::Int
    infections ::Vector{<:AbstractInfection}
    removals   ::Vector{<:AbstractRemoval}
    cremovals  ::Vector{CRemoval}
    chronology ::Vector{<:AbstractIncident}
    trajectory ::Vector{SIR}
    history    ::Vector{AbstractIncident}
    initial    ::SIR
    start      ::Vector{AbstractInfection}
    finis      ::Vector{AbstractRemoval}
    # Remaining (computed) fields are special to `CEvolution`
    LFE        ::Vector{AbstractIncident}
    TLR        ::Vector{Real}
    envelope   ::Vector{Real}
    
    function CEvolution(initial_state::SIR, innovation::Innovation;
                        LFE=AbstractIncident[], TLR=Real[], envelope=Real[])
        # Need to check population == sum of `initial_state` entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation, conditioned=true)
        start, finis    = interval(trajectory, history)
        
        # Move this out!
        #early_inactivated_removals = [z for z ∈ removals if z < start[z.target]]
        #TLR  = repeat([0.0], initial_state.n)
        #for z ∈ early_inactivated_removals
        #    TLR[z.target]  = max(TLR[z.target], z.t)
        #end
        #envelope  = accumulate(max, TLR)
        
        return new(population, infections, removals, cremovals, chronology, 
            trajectory, history, initial_state, start, finis, LFE, TLR, envelope)
    end
    
    function CEvolution(initial_state::SIR, chronology::Vector{AbstractIncident}; 
                        LFE=AbstractIncident[], TLR=Real[], envelope=Real[])
            innovation = Innovation(initial_state.n,
                        AbstractInfection[z for z ∈ chronology if z isa AbstractInfection],
                        AbstractRemoval[z for z ∈ chronology if z isa AbstractRemoval && !(z isa CRemoval)],
                        CRemoval[z for z ∈ chronology if z isa CRemoval]
                        )
        return CEvolution(initial_state, innovation, LFE=LFE, TLR=TLR, envelope=envelope)
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
