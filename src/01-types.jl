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

Expects a field `kind` which is a `String`. This field is
used by function `show`
to represent the particular kind of incident.
"""
abstract type AbstractIncident <: AbstractTimedOccurrence end

# AbstractIncidents representing removals
# -------------------------------
"""
    AbstractRemoval

This represents an abstract removal using a sub-type of [`AbstractIncident`](@ref).  
Inherits requirement for a field `t<:Real` from `AbstractTimedOccurrence`).  
Also expects field `target<:Int`.

If the potential removal is to become realized 
then `target` must index a time line which is infectious just before time `t`.
"""
abstract type AbstractRemoval <: AbstractIncident end

"""
    OperativeRemoval

This represents an _operative_ abstract removal using a sub-type of [`AbstractRemoval`](@ref).
It inherits from `AbstractTimedOccurrence` an expectation of field `t<:Real`. 
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
It inherits from `AbstractTimedOccurrence` an expectation of field `t<:Real`. 
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
Inherits expectation of field `t<:Real` from `AbstractTimedOccurrence`).  
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
It inherits from [`AbstractTimedOccurrence`](@ref) an expectation of field `t<:Real`. 
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
It inherits from [`AbstractTimedOccurrence`](@ref) an expectation of field `t<:Real`.  
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

Represent an infection using a sub-type of [`OperativeInfection`](@ref)
which is structurally identical to `Infection` but with a different name.
Used to identify an [`AbstractInfection`](@ref)
for which the `target` time line is infected and
at which the `infectee` time line is in the no fly zone (`NFT`), moreover
such that the time line immediately below
is not yet in the `NFT` and is not yet infected. 
The `NFT` for the time line immediately below 
is accordingly increased to `z.t` and
the infection is converted into a 
`NoFlyInfection` to signal this change.

Were such an incident actually activated then it would in due course lead
to an error being raised when some
[`Removal`](@ref) 
(as opposed to a [`CRemoval`](@ref)) is activated.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> y = NoFlyInfection(0.2, 1, 2)
𝒩₀.₂₀¹⁻²
julia> z = Infection(0.2, 1, 2) ;

julia> NoFlyInfection(z) == y
true
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
Intended to identify an `Infection` which 
will never be activated because
its `target` time line is not infected.

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

Represent an infection using a sub-type of [`NonOperativeInfection`](@ref)
which is otherwise identical to `Infection` but with a different name.
Intended to identify an [`AbstractInfection`](@ref)
for which the `target` time line is infected and
at which the `infectee` time line is in the no fly zone (`NFT`), moreover
such that the time line immediately below is infected (and hence cannot be in
the `NFT`).  

Were such an incident to be present then it would immediately be activated, would then
infect the `NFT` and would thus lead to raising
of
an error being raised when a [`Removal`](@ref) 
(as opposed to a [`CRemoval`](@ref)) is activated.
It is therefore converted into 
an [`ExpungedInfection`](@ref),
which (being a [`NonOperativeInfection`](@ref))
will never be activated.


### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> y = ExpungedInfection(0.2, 1, 2)
𝒳₀.₂₀¹⁻²
julia> z = Infection(0.2, 1, 2) ;

julia> ExpungedInfection(z) == y
true
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

# Structures for `S-I-R` epidemics
# -------------------------------

# ### An `SIR` state for an $\SIR$ epidemic
"""
    SIR(::Real, ::Int, ::Int, ::Int)

This represents a state `sir` of a `S-I-R` epidemic
(with fields `s`, `i`, `r` being non-negative integers adding up to the
the population size `n`)
at a specified time `t` (a real number). Note that `n` is 
a computed field, calculated
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
and also **computed** fields `chronology`, `trajectory` and `history`.

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
    
    function Evolution(initial_state::SIR, innovation::Innovation)
        # Need to check population == sum of initial.state entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation)
        start, finis    = interval(trajectory, history)
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
    CEvolution(::SIR, ::Innovation; LFE::Vector{AbstractIncident}=AbstractIncident[],
        NFZ1=Real[], NFZ2=Real[], NFZ3=Real[])::CEvolution
    CEvolution(SIR, Vector{AbstractIncident}; 
                LFE=AbstractIncident[], NFZ1=Real[], NFZ2=Real[], NFZ3=Real[])::CEvolution
    CEvolution(::AbstractEvolution, ::Innovation)::CEvolution

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
and also **computed** fields `chronology`, `trajectory` and `history`.
Note the implicit use of [`evolution`](@ref) (with the `conditioned` flag set to `true`)
to compute the `trajectory` and `history` fields,
and the implicit use of [`EpidemicsCFTP.interval`](@ref) to compute start and finish incidents
for infectious intervals.

It possesses extra fields `LFE`, `NFZ1`,  `NFZ2`, and `NFZ3` which are respectively
the incidents involved in the last feasible epidemic, the maxima _per_ time line
of times of `Removal`s occurring _before_ the epidemic trajectory as measured
by `start`, the monotonically increasing envelope of `NFZ1`, and the region which must
not be infected if we are not to violate conditioning on removals.

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

julia> ev = CEvolution(initial, infections ∪ removals ∪ cremovals, NFZ1=[0.5])
CEvolution(3,
infections: AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒦₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹]
chronology: AbstractIncident[𝒩₀.₀₀²⁻³,𝒞₀.₀₀¹,ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒳₀.₂₀²⁻³,𝒦₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])

julia> ev.NFZ1 == Real[0.5]
true
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
    # Remaining fields are special to `CEvolution`
    LFE        ::Vector{AbstractIncident}
    NFZ1       ::Vector{Real}
    NFZ2       ::Vector{Real}
    NFZ3       ::Vector{Real}
    
    function CEvolution(initial_state::SIR, innovation::Innovation;
                        LFE=AbstractIncident[], NFZ1=Real[], NFZ2=Real[], NFZ3=Real[])
        # Need to check population == sum of `initial_state` entries
        population          = innovation.population
        infections          = innovation.infections
        removals            = innovation.removals
        cremovals           = innovation.cremovals   
        chronology          = innovation.chronology
        trajectory, history = evolution(initial_state, innovation, conditioned=true)
        start, finis        = interval(trajectory, history)
        
        return new(population, infections, removals, cremovals, chronology, 
            trajectory, history, initial_state, start, finis, LFE, NFZ1, NFZ2, NFZ3)
    end
    
    function CEvolution(initial_state::SIR, chronology::Vector{AbstractIncident}; 
                        LFE=AbstractIncident[], NFZ1=Real[], NFZ2=Real[], NFZ3=Real[])
            innovation = Innovation(initial_state.n,
                        AbstractInfection[z for z ∈ chronology if z isa AbstractInfection],
                        AbstractRemoval[z for z ∈ chronology if z isa AbstractRemoval && !(z isa CRemoval)],
                        CRemoval[z for z ∈ chronology if z isa CRemoval]
                        )
        return CEvolution(initial_state, innovation, LFE=LFE, NFZ1=NFZ1, NFZ2=NFZ2, NFZ3=NFZ3)
    end

function CEvolution(ev::AbstractEvolution, iv::Innovation)::CEvolution
    # Step 1.
    @assert length(ev.cremovals) == length(iv.cremovals)
    @assert all(x.t == y.t for (x,y) ∈ zip(ev.cremovals, iv.cremovals))
    
    # Step 2.
    removals = EpidemicsCFTP.inactive_removals(ev, iv)
    
    # Step 3.
    cremovals  = EpidemicsCFTP.resulting_cremovals(ev, iv.cremovals)
    
    # Step 4.
    duration = maximum(z.t for z in cremovals)
    LFE = EpidemicsCFTP.last_feasible_evolution(duration, ev, 
                iv.infections, cremovals, conditioned=true)
    perpetuated_infections = P[P(z) for z ∈ LFE ∩ ev.infections] 
    
    # Step 5.
    # * Initial computation of `NFZ2`, a **list of times** 
    # indexed by time line ("level"), where each time is initially defined as
    # the supremum of times of **inactivated** `Removal`s at given level or 
    # below. So the envelope increases monotonically with level.
    NFZ1 = repeat([-Inf], ev.initial.n)
    for z ∈ [z for z ∈ removals if z < ev.finis[z.target]]
        NFZ1[z.target] = max(NFZ1[z.target], z.t)
    end
    NFZ2 = accumulate(max, NFZ1)
 
    # The hard work begins! We generate the NFZ3.
    # * The list `processed_infections` of processed `AbstractInfection`s will
    # eventually store (initially in reverse time order) an adjusted version of
    # each infection supplied by the new `Innovation` `iv`.
	processed_infections = AbstractInfection[]
	NFZ3 = deepcopy(NFZ2)
	
	# * Iteration: work backwards through `Infection`s supplied by `iv`
	# together with perpetuated infections,
    # determining in each case how to transform the supplied `Infection`
    # when adding it to the list `processed_infections`.
	for z ∈ reverse(sort(iv.infections ∪ perpetuated_infections))
	    
	    # * If the `Infection` `z` has `target` on the removed portion of a level
        # then it will never be activated, so add `z` as a `KilledInfection`.
	    if (z ≥ ev.finis[z.target])
	        push!(processed_infections, KilledInfection(z))
	        continue
	    end
	    
	    # * If the `Infection` `z` potentially infects a level at a _later time_ 
        # than the current `NFZ2` at that level, then its activation will
        # never break the conditioning (**needs proof!**), so add `z` as-is.
        # (I think the point is: since we are working backwards in time, once
        # `z.t` is considered then `NFZ2` is frozen from time `t` onwards.)
	    #
	    # At this stage of the iteration 
	    @assert(z < ev.finis[z.target])
	    #
        if (z.t ≥ NFZ3[z.infectee])
	        push!(processed_infections, z)
	        continue
	    end
	    
	    # * However if `z.t < NFZ2[z.infectee - 1]` then no issue can arise, as 
        # infection of the level immediately below `z.infectee` will then not be
        # allowed at this time. So again add `z` as-is.
        #
	    # At this stage of the iteration 
	    @assert(z < ev.finis[z.target])
	    @assert(z.t < NFZ3[z.infectee])
	    #
        if (z.t < NFZ3[z.infectee - 1])
	        push!(processed_infections, z)
	        continue
	    end
	    
	    # * Suppose `z ≥ ev.start[z.target]`: then an issue would arise
        # if the level at `z.infectee - 1` were to become infected before `z.t`. 
        #
	    # At this stage of the iteration 
	    @assert(z.t < NFZ3[z.infectee])
	    @assert(z.t ≥ NFZ3[z.infectee - 1])
	    @assert(z < ev.finis[z.target])
	    #
	    # One of two cases must hold:
	    #
	    # * Case (a): Suppose `z < ev.start[z.infectee - 1]`.
        # Then **increase** `NFZ2[z.infectee - 1]` to `z.t` in order to
        # preclude the time line getting infected, and also transform `z` to a
        # `NoFlyInfection` when added to `processed_infections`, to signal
        # that it should never become infected.  
        # Case (b): Alternatively, suppose `z ≥ ev.start[z.infectee - 1]`.
        # Then increasing `NFZ2[z.infectee - 1]` to `z.t` would lead to a
        # problem, since this level is infected at time `z.t`. Therefore we
        # transform `z` to a `ExpungedInfection` when we add it to 
        # `processed_infections`, so that it is treated as an
        # `InoperativeInfection`.
	    if (z ≥ ev.start[z.target])
            if (z < ev.start[z.infectee - 1])
                NFZ3[z.infectee - 1] = z.t
                push!(processed_infections, NoFlyInfection(z))
                # Uncomment for tracking information
                # @info "Conversion of infection into $(NoFlyInfection(z))"
                continue
            else 
                push!(processed_infections, ExpungedInfection(z))
                # Uncomment for tracking information
                # @info "Conversion of infection into $(ExpungedInfection(z))"
                continue 
            end 
	    end
	    
	    # At this stage of the iteration 
	    @assert(z.t < NFZ3[z.infectee])
	    @assert(z.t ≥ NFZ3[z.infectee - 1])
	    @assert(z < ev.start[z.target])
	    # 
	    # * Consider now that potential `Infection`s to be treated later in this
        # iteration must have time mark earlier than `z.t`. If one of these were
        # to infect the level `z.infectee - 1` then it would follow by monotonicity
        # that the `z.target` level would become infected by that time `z.t`; and 
        # thus would create an infection of the `z.infectee` level at time `z.t`. 
        # In order for this to be prevented, we need to extend the `NFZ2` 
        # at level `z.infectee - 1` up to time `z.t`. We also transform `z`
        # to a `NoFlyInfection` when we add it to `processed_infections`, to
        # signal that it should never become infected.
	    NFZ3[z.infectee - 1] = z.t 
	    push!(processed_infections, NoFlyInfection(z))
        # Uncomment for tracking information
        # @info "Conversion of infection into $(NoFlyInfection(z))"
	
	end
    
    # Return the new `CEvolution`: NOTE it is built using a new `Innovation` `iv_mod`!
    iv_mod = Innovation(ev.initial.n, processed_infections, removals, cremovals)
    return CEvolution(ev.initial, iv_mod, LFE=LFE, NFZ1=NFZ1, NFZ2=NFZ2, NFZ3=NFZ3)
end

end
