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

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `AbstractIncident` as `AI`.
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

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `AbstractRemoval` as `AIR`.
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

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `AbstractInfection` as `AIF`.
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

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `Removal` as `R`.

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

    function Removal(t::Real, target::Int)
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

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `CRemoval` as `C`.

### Example
```jldoctest
julia> CRemoval(0.1, 4)
𝒞₀.₁₀⁴
```
"""
struct CRemoval <: OperativeRemoval
    kind      ::String     
    t         ::Float64
    target    ::Int

    function CRemoval(t::Real, target::Int) 
        noun = "CRemoval($t, $target)"
        return (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("𝒞", float(t), target))
    end

@doc """
    CRemoval(z::AbstractRemoval)::CRemoval

Converts an [`AbstractRemoval`](@ref) to a `CRemoval`. 

### Example
```jldoctest
julia> CRemoval(R(0.1, 4))
𝒞₀.₁₀⁴
```
"""
function CRemoval(z::AbstractRemoval)::CRemoval
    return CRemoval(z.t, z.target)
end
end


"""
    KilledRemoval(::Float64, ::Int)

Implements a removal which can never be activated using a sub-type of [`AbstractRemoval`](@ref).  
The `target` field labels the timeline being considered as host for the removal incident: it must be a positive integer.  

A `KilledRemoval` should be created (by conversion) only in:

* [`EpidemicsCFTP.kill_irrelevant_removals`](@ref) 
* one of the constructors of [`CEvolution`](@ref CEvolution(ev::AbstractEvolution, iv::AbstractInnovation));
* and [`EpidemicsCFTP.inactive_removals`](@ref)  
(This list of functions should be reduced!),

and it should be the case that `KilledRemoval`s are precisely those
`AbstractRemoval`s which have `target` in the removal zone.

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `KilledRemoval` as `KR`.

### Example
```jldoctest
julia> KilledRemoval(0.1, 4)
𝒦₀.₁₀⁴
```
"""
struct KilledRemoval <: NonOperativeRemoval
    kind      ::String     
    t         ::Float64
    target    ::Int

function KilledRemoval(t::Real, target::Int)
    noun = "KilledRemoval($t, $target)"
    return (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
            new("𝒦", float(t), target))
end

@doc """
    KilledRemoval(::AbstractRemoval)::KilledRemoval
    
Converts an [`AbstractRemoval`](@ref) to a `KilledRemoval`. **In the future**
this should happen _only_ at the
stage of creating an [`Innovation`](@ref) containing [`CRemoval`](@ref)s, in which case the `CRemoval`s
determine the `finis` times of all actual infectious periods, so that we can ascertain
precisely which `AbstractRemoval`s should be converted to `KilledRemoval`s.

### Example
```jldoctest
julia> KilledRemoval(R(0.1, 4))
𝒦₀.₁₀⁴
```
"""
function KilledRemoval(z::AbstractRemoval)::KilledRemoval
    return KilledRemoval(z.t, z.target)
end
end

"""
    RemovalMarker(::Float64, ::Int)

This is a marker normally placed at the end of an epidemic to signal completion of infected time lines.

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `RemovalMarker` as `RM`.
### Example
```jldoctest
julia> RemovalMarker(0.1, 4)
ℳ⁺₀.₁₀⁴
```
"""
struct RemovalMarker <: NonOperativeRemoval
    kind      ::String
    t         ::Float64
    target    ::Int
    
    function RemovalMarker(t::Real, target::Int)
        noun = "RemovalMarker($t, $target)"
        return (target ≤ 0 ? throw(DomainError(noun, "non-positive mark")) :
                new("ℳ⁺", float(t), target))
    end

@doc """
    function RemovalMarker(::AbstractRemoval)::RemovalMarker
    
Converts an [`AbstractRemoval`](@ref) to a `RemovalMarker`.

### Example
```jldoctest
julia> RemovalMarker(R(0.1, 4))
ℳ⁺₀.₁₀⁴
```
"""
function RemovalMarker(z::AbstractRemoval)::RemovalMarker
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

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `Infection` as `I`.

### Example
```jldoctest
julia> Infection(0.2, 1, 2)
ℐ₀.₂₀¹⁻²
```
"""
struct Infection <: OperativeInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int

    function Infection(t::Real, target::Int, infectee::Int)
        noun = "Infection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark(s)"))
        else
            new("ℐ", float(t), target, infectee)
        end
    end

@doc """
    Infection(z::AbstractInfection)::Infection
    
Converts an [`AbstractInfection`](@ref) to an `Infection`.

### Example
```jldoctest
julia> Infection(I(0.2, 1, 2))
ℐ₀.₂₀¹⁻²
```
"""
function Infection(z::AbstractInfection)::Infection
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

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `PInfection` as `P`.

### Example
```jldoctest
julia> PInfection(0.2, 1, 2)
𝒫₀.₂₀¹⁻²
```
"""
struct PInfection <: OperativeInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function PInfection(t::Real, target::Int, infectee::Int)
        noun = "PInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            return new("𝒫", float(t), target, infectee)
        end
    end

@doc """
    PInfection(z::AbstractInfection)::PInfection
    
Converts an [`AbstractInfection`](@ref) to a `PInfection`.
We often refer to this as "perpetuation".

### Example
```jldoctest
julia> PInfection(I(0.2, 1, 2))
𝒫₀.₂₀¹⁻²
```
"""    
function PInfection(z::AbstractInfection)::PInfection
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

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `NoFlyInfection` as `NF`.

### Example
```jldoctest
julia> NoFlyInfection(0.2, 1, 2)
𝒩₀.₂₀¹⁻²
```
"""
struct NoFlyInfection <: OperativeInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function NoFlyInfection(t::Real, target::Int, infectee::Int) 
        noun = "NoFlyInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            return new("𝒩", float(t), target, infectee)
        end
    end
    
@doc """
    NoFlyInfection(z::AbstractInfection)::NoFlyInfection

Converts an [`AbstractInfection`](@ref) to a `NoFlyInfection`.
### Example
```jldoctest
julia> NoFlyInfection(I(0.2, 1, 2))
𝒩₀.₂₀¹⁻²
```
"""
function NoFlyInfection(z::AbstractInfection)::NoFlyInfection
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

A `KilledInfection` should be created (by conversion) only in the functions

* [`EpidemicsCFTP.last_feasible_evolution`](@ref),
* [`EpidemicsCFTP.kill_irrelevant_infections`](@ref),
* one of the constructors of [`CEvolution`](@ref CEvolution(ev::AbstractEvolution, iv::AbstractInnovation));
* and [`EpidemicsCFTP.compute_nofly`](@ref)  
(This list of functions should be reduced!).

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `KilledInfection` as `KI`.

### Example
```jldoctest
julia> KilledInfection(0.2, 1, 2)
𝒦₀.₂₀¹⁻²
```
"""
struct KilledInfection <: NonOperativeInfection

    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function KilledInfection(t::Real, target::Int, infectee::Int)
        noun = "KilledInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            return new("𝒦", float(t), target, infectee)
        end
    end
    
@doc """
    KilledInfection(::AbstractInfection)::KilledInfection

Converts an [`AbstractInfection`](@ref) to a `KilledInfection`.
### Example
```jldoctest
julia> KilledInfection(I(0.2, 1, 2))
𝒦₀.₂₀¹⁻²
```
"""
function KilledInfection(z::AbstractInfection)::KilledInfection
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

Ensure that it is the case that `ExpungedInfection`s arise **only** in this way!
This occurs in:

* the function [`compute_nofly`](@ref).

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `ExpungedInfection` as `XI`.

### Example
```jldoctest
julia> ExpungedInfection(0.2, 1, 2)
𝒳₀.₂₀¹⁻²
```
"""
struct ExpungedInfection <: NonOperativeInfection

    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function ExpungedInfection(t::Real, target::Int, infectee::Int)
        noun = "ExpungedInfection($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target ≤ 0
            throw(DomainError(noun, "non-positive mark"))
        else
            return new("𝒳", float(t), target, infectee)
        end
    end

@doc """
    ExpungedInfection(::AbstractInfection)::ExpungedInfection

Converts an [`AbstractInfection`](@ref) to a `ExpungedInfection`.
### Example
```jldoctest
julia> ExpungedInfection(I(0.2, 1, 2))
𝒳₀.₂₀¹⁻²
```
"""
function ExpungedInfection(z::AbstractInfection)::ExpungedInfection
    return ExpungedInfection(z.t, z.target, z.infectee)
end
end

"""
    InfectionMarker(::Float64, ::Int, ::Int)

This is a marker normally placed at the start of an epidemic to signal initial infected time lines.
Differs from (for example) `Infection` in that the `target` mark can be zero.

The submodule [`.abbreviations`](@ref EpidemicsCFTP.abbreviations) abbreviates `InfectionMarker` as `IM`.
### Example
```jldoctest
julia> InfectionMarker(0.2, 1, 2)
ℳ⁻₀.₂₀¹⁻²
```
"""
struct InfectionMarker <: NonOperativeInfection
    kind      ::String
    t         ::Float64
    target    ::Int
    infectee  ::Int
    
    function InfectionMarker(t::Real, target::Int, infectee::Int) 
        noun = "InfectionMarker($t, $target, $infectee)"
        if infectee ≤ target
            throw(DomainError(noun, "disordered marks"))
        elseif target < 0
            throw(DomainError(noun, "negative mark"))
        else
            return new("ℳ⁻", float(t), target, infectee)
        end
    end
    
@doc """
    InfectionMarker(::AbstractInfection)::InfectionMarker

Converts an [`AbstractInfection`](@ref) to an `InfectionMarker`.
### Example
```jldoctest
julia> InfectionMarker(I(0.2, 1, 2))
ℳ⁻₀.₂₀¹⁻²
```
"""
function InfectionMarker(z::AbstractInfection)::InfectionMarker
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

### Example
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

Represents variants of an entire innovation or environment structure
for a single step of algorithmic time.
"""
abstract type AbstractEnvironment end

# ### Innovations
"""
    AbstractInnovation

Represents variants of an entire innovation
for a single step of algorithmic time.
It is a generic sub-type of [`AbstractEnvironment`](@ref)
"""
abstract type AbstractInnovation <: AbstractEnvironment end

"""
    Innovation

This represents an entire unconditioned innovation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals).

Note that there is a first argument `population` (an `Int`),
incident lists of `AbstractInfection`, `AbstractRemoval`, and `CRemoval`,
a computed field `chronology` holding a
time-ordered list of the union of the incident lists,
and five keyword parameters `t0`, `duration`, `size`, `α`, and `β`.
Note that `size`, `α`, and `β` are initialized at unrealistic negative values
while `t0` and `duration` are initialized at unrealistic infinite values.
If they are used (for example for random generatioon) then there is a need to test that they
have been assigned realistic values.
"""
struct Innovation <: AbstractInnovation
    population ::Int
    size       ::Int
    t0         ::Real
    duration   ::Real
    infections ::Vector{<:AbstractInfection}
    removals   ::Vector{<:AbstractRemoval}
    cremovals  ::Vector{CRemoval}
    chronology ::Vector{<:AbstractIncident}
    α          ::Real
    β          ::Real

@doc """
    Innovation(::Int, ::Vector{<:AbstractInfection}, ::Vector{<:AbstractRemoval}, ::Vector{CRemoval};
                t0::Real=-Inf, duration::Real=Inf, size::Int=-1, α::Real=-1.0, β::Real=-1.0) 
This is the usual basic creation of an `Innovation`, specifying
all of `infections`, `removals`, and `cremovals`.
### Example
```jldoctest innovation; setup = :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations)
population = 3
infections = [I(0.7,1,2), P(0.5,1,2)]
removals   = [R(0.2, 3), R(0.1, 2)]
cremovals  = [C(0.0, 1), C(0.05, 2)]
Innovation(population, infections, removals, cremovals)

# output
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²])  
```
"""
function Innovation(population::Int, infections::Vector{<:AbstractInfection},
                    removals::Vector{<:AbstractRemoval},
                    cremovals::Vector{CRemoval};
                    t0::Real=-Inf, duration::Real=Inf, size::Int=0, α::Real=0.0, β::Real=0.0) 
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
        return new(population, size, t0, duration,
                    sort(infections), sort(removals), sort(cremovals),
                    convert(Vector{AI}, sort(infections ∪ removals ∪ cremovals)),
                    α, β)
    end
end

@doc """
    Innovation(::Int, ::Vector{<:AbstractInfection}, ::Vector{<:AbstractRemoval};
                    t0::Real=-Inf, duration::Real=Inf, size::Int=-1, α::Real=-1.0, β::Real=-1.0)
    
Variant which omits `cremovals` list.

### Example
```jldoctest innovation; setup = :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations)
population = 3
infections = [I(0.7,1,2), P(0.5,1,2)]
removals   = [R(0.2, 3), R(0.1, 2)]

Innovation(population, infections, removals)

# output
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]) 
```
"""
function Innovation(population::Int, 
                    infections::Vector{<:AbstractInfection}, removals::Vector{<:AbstractRemoval};
                    t0::Real=-Inf, duration::Real=Inf, size::Int=-1, α::Real=-1.0, β::Real=-1.0)
    return Innovation(population, infections, removals, CRemoval[];
                      t0=t0, duration=duration, size=size, α=α, β=β)
end

@doc """
    Innovation(::Int, ::Vector{AbstractIncident};
                t0::Real=-Inf, duration::Real=Inf, size::Int=-1, α::Real=-1.0, β::Real=-1.0)
    
Variant of `Innovation` based on a time-ordered `chronology` of `AbstractIncident`s.

### Example
```jldoctest innovation; setup = :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations)
population = 3
chron      = [R(0.1, 2), R(0.2, 3), I(0.7,1,2), P(0.5,1,2), C(1,2)]

Innovation(population, chron)

# output
Innovation(3,
infections: AbstractInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₁.₀₀²])
```
"""
function Innovation(population::Int, chronology::Vector{AbstractIncident};
                    t0::Real=-Inf, duration::Real=Inf, size::Int=-1, α::Real=-1.0, β::Real=-1.0)
    infections = convert(Vector{AIF}, filter(z -> z isa AIF, chronology))
    removals   = convert(Vector{AIR}, filter(z -> (z isa AIR) && !(z isa C), chronology))
    cremovals  = C.(filter(z -> (z isa C), chronology))
    return Innovation(population, infections, removals, cremovals;
                       t0=t0, duration=duration, size=size, α=α, β=β)
end

end
    
# ### Abstract evolution for an $\SIR$ epidemic
"""
    AbstractEvolution 

This represents variants of evolution of an `S-I-R` epidemic.
It is a generic sub-type of [`AbstractEnvironment`](@ref)
"""
abstract type AbstractEvolution <: AbstractEnvironment end

# ### (Unconditioned) evolution for an $\SIR$ epidemic
"""
    Evolution

This represents an _unconditional_ evolution of an SIR epidemic 
based on a given [`AbstractInnovation`](@ref) 
for innovations,
and starting from a given [`SIR`](@ref) for initial state.

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals),
initial state `initial`,
and also **computed** fields `chronology`, `trajectory` and `history`.

Note that [`evolution`](@ref) (with the `conditioned` flag at default of `false`)
is used in the course of the constructions to compute the `trajectory` and `history` fields,
while [`create_start`](@ref) and [`create_finis`](@ref) are used in the course of the constructions 
to compute lists of start and finish incidents
for infectious intervals.

The field `size` currently plays no role.

The field `t0` (initial time) is either assigned as a keyword parameter or computed using 
`initial`.

The field `duration` (length of time period of evolution) is either assigned as a keyword parameter or computed using 
`initial` and `chronology`.


The fundamental constructor of `Evolution` uses `deepcopy` for the fields `infections`, 
`removals`, and `cremovals` to avoid embarrassing bugs if the source lists are later modified!

See [`Evolution(::SIR,::AbstractInnovation)`](@ref Evolution(::SIR, ::AbstractInnovation)) 
and [`Evolution(::SIR,::Vector{AbstractIncident})`](@ref Evolution(::SIR, ::Vector{AbstractIncident})) 
below for examples of construction.

### Example
We illustrate here the behaviour of the `start` and `finis` fields
```jldoctest evolution_doctest
julia> using EpidemicsCFTP, EpidemicsCFTP.abbreviations ;

julia> initial = SIR(0,2,1,0) ;

julia> iv = Innovation(initial.n, [NF(14,1,2),P(10,1,2)],[R(4,3),R(2, 2)],[C(0,1), C(1, 2)]) ;

julia> ev = Evolution(initial, iv) ;

julia> ev.start
AbstractInfection[ℳ⁻[-∞]⁰⁻¹,ℳ⁻[∞]¹⁻²,ℳ⁻[∞]²⁻³]
julia> ev.finis
AbstractRemoval[𝒞₀.₀₀¹,ℳ⁺[∞]²,ℳ⁺[∞]³]
```
"""
struct Evolution <: AbstractEvolution
    population  ::Int
    size        ::Int
    infections  ::Vector{<:AbstractInfection}
    removals    ::Vector{<:AbstractRemoval}
    cremovals   ::Vector{CRemoval}
    chronology  ::Vector{<:AbstractIncident}
    trajectory  ::Vector{SIR}
    history     ::Vector{AbstractIncident}
    initial     ::SIR
    start       ::Vector{AbstractInfection}
    finis       ::Vector{AbstractRemoval}
    t0          ::Real
    duration    ::Real

@doc """
    Evolution(::SIR, ::AbstractInnovation)::Evolution

An `Evolution` can be constructed using only an `initial` state 
and an `AbstractInnovation`.

### Example
```jldoctest
initial    = SIR(0, 2, 1, 0)
population = initial.n
infections = [NF(0.7,1,2), P(0.5,1,2)]
removals   = [R(0.2, 3), R(0.1, 2)] 
cremovals  = [C(0.0, 1), C(0.05, 2)]
innov      = Innovation(population, infections, removals, cremovals)
Evolution(initial, innov)

# output
Evolution(SIR₀.₀₀(2:1:0),
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
chronology: AbstractIncident[𝒞₀.₀₀¹,𝒞₀.₀₅²,ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])
```
"""
function Evolution(initial_state::SIR, innovation::AbstractInnovation;
                   size::Int=0, t0::Real=-Inf, duration::Real=Inf)::Evolution
        # Need to check population == sum of initial.state entries
        population = innovation.population
        infections = innovation.infections
        removals   = innovation.removals
        cremovals  = innovation.cremovals   
        chronology = innovation.chronology
        trajectory, history = evolution(initial_state, innovation)
        start      = create_start(trajectory[1], history)
        finis      = create_finis(trajectory[1], history)
        if t0 == -Inf
            t0 = minimum(z.t for z in chronology)
        end
        if duration == Inf
            duration = maximum(z.t for z in chronology) - t0
        end
        return new(population, size, deepcopy(infections), deepcopy(removals), deepcopy(cremovals), 
                   chronology, trajectory, history, initial_state, start, finis, 
                   t0, duration)
    end
    
@doc """
    Evolution(::SIR, ::Vector{AbstractIncident})::Evolution

An `Evolution` can be constructed using only an `initial` state 
and a `chronology` (a `Vector{AbstractIncident}` of `AbstractIncident`s
in increasing order).
### Example 
```jldoctest
initial    = SIR(0, 2, 1, 0)
population = initial.n
infections = [NF(0.7,1,2), P(0.5,1,2)]
removals   = [R(0.2, 3), R(0.1, 2)] 
cremovals  = [C(0.0, 1), C(0.05, 2)]
Evolution(initial, infections ∪ removals ∪ cremovals)

# output
Evolution(SIR₀.₀₀(2:1:0),
infections: AbstractInfection[𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹,𝒞₀.₀₅²]
chronology: AbstractIncident[𝒞₀.₀₀¹,𝒞₀.₀₅²,ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,𝒩₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])
```
"""
function Evolution(initial_state::SIR, chronology::Vector{<:AbstractIncident};
                   size::Int=0, t0::Real=-Inf, duration::Real=Inf)::Evolution
    innovation = Innovation(initial_state.n,
                        AIF[z for z ∈ chronology if z isa AIF],
                        AIR[z for z ∈ chronology if z isa AIR && !(z isa C)],
                        C[z for z ∈ chronology if z isa C],
                        )
    return Evolution(initial_state, innovation; size=size, t0=t0, duration=duration)
end

end

                        
# # ### (Conditioned) evolution for an $\SIR$ epidemic
"""
    CEvolution::AbstractEvolution

This implements _conditional_ evolution of an SIR epidemic 
based on a given [`Innovation`](@ref) 
for innovations,
and starting from a given [`SIR`](@ref) for initial state.
An error is raised if the resulting [`evolution`](@ref) activates
an [`AbstractRemoval`](@ref) incident which is not a [`CRemoval`](@ref).

It represents an entire simulation corresponding to a single step of _algorithmic_ time,
stored as a sequence of three **time-ordered** lists 
(realized and unrealized infections, unrealized removals, conditional removals),
initial state `initial`,
and also **computed** fields `chronology`, `trajectory` and `history`.
Note the implicit use of [`evolution`](@ref) (with the `conditioned` flag set to `true`)
to compute the `trajectory` and `history` fields,
and the implicit use of [`create_start`](@ref)
and [`create_finis`](@ref) 
to compute start and finish incidents
for infectious intervals.

It possesses extra fields `LFE`, `NFZ1`,  `NFZ2`, and `NFZ` which are respectively
the incidents involved in the last feasible epidemic, the maxima _per_ time line
of times of `Removal`s occurring _before_ the epidemic trajectory as measured
by `start`, the monotonically increasing envelope of `NFZ1`, and the region which must
not be infected if we are not to violate conditioning on removals.

If field `size` is positive (in fact, no smaller than the total number of `CRemoval`s)
then this serves as a further constraint on the `initial` field.

The field `t0` (initial time) is either assigned as a keyword parameter or computed using 
`initial`.

The field `duration` (length of time period of evolution) is either assigned as a keyword parameter or computed using 
`initial` and `chronology`.

The fundamental constructor of `CEvolution` uses `deepcopy` for the fields `infections`, 
`removals`, and `cremovals` to avoid embarrassing bugs if the source lists are later modified!

There are three different derived constructors discussed below:

* updating an [`AbstractEvolution`](@ref) using a candidate `Innovation` (preferred),
* using an [`Innovation`](@ref), 
* using a `chronology` of incidents,

### Example
We begin with illustration of a chronology (we will repeat this construction below!).
```jldoctest CEvolution_setup
initial    = SIR(0.0, 2, 1, 0)
population = initial.n
infections = [NF(0,2,3), XI(0.2, 2, 3), I(0.7,1,2), P(0.5,1,2)]
removals   = [R(0.1, 1), KR(0.2, 3), R(0.1, 2)]
cremovals  = [C(0.0, 1)]
chronology = infections ∪ removals ∪ cremovals

# output
AbstractIncident[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℛ₀.₁₀¹,𝒦₀.₂₀³,ℛ₀.₁₀²,𝒞₀.₀₀¹]
```
"""
struct CEvolution <: AbstractEvolution
    population ::Int
    size       ::Int
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
    NFZ        ::Vector{Real}
    t0         ::Real
    duration   ::Real

@doc """
        CEvolution(::AbstractEvolution, ::AbstractInnovation; size::Int=0)::CEvolution

This is the first way to construct a [`CEvolution`](@ref): 
updating an [`AbstractEvolution`](@ref) using a candidate `Innovation`.
The procedure is as follows:

1. Test for compatibility between `ev` and `iv`:  
    * Check the `cremoval` lists have the same length;
    * Check the `cremoval` lists generate the same times ('t' field).
2. Use [`inactive_removals`](@ref) to form the new `removals` list by selecting only those `AbstractRemoval`s from `iv.removals` which will not be activated. Type is changed to [`KilledRemoval`](@ref)
for an `AbstractRemoval` occurring after removal time for the corresponding time line. Note that the function discards `Removal`s (as opposed to `CRemoval`s) which _would_ be activated. 
3. Form the new `cremovals` list using [`resulting_cremovals`](@ref), by choosing from `iv.cremovals` if activated, otherwise staying with `ev.cremovals`.
4. Compute `LFE`. Note `cremovals` has already been computed in step 3. Compute `perpetuated_infections` as perpetuations of infections from `LFE` which are original infections.
5. Compute time of last removal per time line (`NFZ1`) and monotonically non-decreasing envelope (`NFZ2`):  
    * select out those `AbstractRemoval`s occurring before actual removal time on each time line;
    * compute `NFZ1`;
    * and generate `NFZ2`.
6. Now use `compute_nofly` to compute the "no fly zone".
7. Then generate the next `CEvolution` using the new `removals` and `cremovals` lists, the new `processed_infections` list, and associated lists `LFE`, `NFZ1`, `NFZ2` and `NFZ`.


### Example
```jldoctest CEvolution_setup
initial    = SIR(0.0, 2, 1, 0)
population = initial.n
infections = [NF(0,2,3), XI(0.2, 2, 3), I(0.7,1,2), P(0.5,1,2)]
removals   = [R(0.1, 1), KR(0.2, 3), R(0.1, 2)]
cremovals  = [C(0.0, 1)]
chronology = infections ∪ removals ∪ cremovals
ev = CEvolution(initial, chronology) ;
candidate = Innovation(population, I[], R[], cremovals) ;
CEvolution(ev, candidate)

# output
CEvolution(SIR₀.₀₀(2:1:0),
infections: AbstractInfection[]
removals:   AbstractRemoval[]
cremovals:  CRemoval[𝒞₀.₀₀¹]
chronology: AbstractIncident[𝒞₀.₀₀¹]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])
```

Note also the abbreviation of `CEvolution(ev, candidate)`
as `ev ⋄ candidate`.

We also cover here two ways in which exceptions can be raised.

#### What happens on missing a conditioned removal:
```jldoctest CEvolution_setup
cremovals1 = sort(cremovals ∪ [C(0.0, 2)]) ;
innov = Innovation(population, Infection[], Removal[], cremovals1) ;
CEvolution(initial, innov)

# output
ERROR: [MissedCRemoval] The (conditioned) evolution failed to employ CRemoval(0.0, 2)
```

#### What happens on employing an (unconditioned) removal:
```jldoctest CEvolution_setup
removals   = [R(0.1, 1), R(0.1, 2)] ;
cremovals  = [C(0.2, 1)] ;
innov      = Innovation(population, infections, removals, cremovals) ;
CEvolution(initial, innov)

# output
ERROR: [EmployedRemoval] The (conditioned) evolution wrongly employed Removal(0.1, 1)
```
"""
function CEvolution(ev::AbstractEvolution, iv::AbstractInnovation; 
                    size::Int=0, t0::Real=-Inf, duration::Real=Inf)::CEvolution
    # import EpidemicsCFTP: inactive_removals,
    #                       resulting_cremovals,
    #                       last_feasible_evolution,
    #                       compute_nofly
    @assert length(ev.cremovals) == length(iv.cremovals)
    @assert all(x.t == y.t for (x,y) ∈ zip(ev.cremovals, iv.cremovals))
    
    removals = inactive_removals(ev, iv)
    
    recomputed_cremovals  = resulting_cremovals(ev, iv.cremovals)
    
    duration = maximum(z.t for z in recomputed_cremovals)
    LFE = last_feasible_evolution(duration, ev, iv)
    perpetuated_infections = P[z for z ∈ LFE if z isa P] 
    
    NFZ1 = repeat([-Inf], ev.initial.n)                                     # <1>
    for z ∈ [z for z ∈ removals if z < ev.finis[z.target]]
        NFZ1[z.target] = max(NFZ1[z.target], z.t)
    end
    NFZ2 = accumulate(max, NFZ1)

    processed_infections, nofly_bound =                                     # <2>
        compute_nofly(ev, iv.infections ∪ perpetuated_infections, NFZ2)
    
    # Return the new `CEvolution`: NOTE it is built using a new `Innovation` `iv_mod`!
    iv_mod = Innovation(ev.initial.n, processed_infections, removals, recomputed_cremovals)
    return CEvolution(ev.initial, iv_mod; LFE=LFE, NFZ1=NFZ1, NFZ2=NFZ2, NFZ=nofly_bound, 
                      size=size, t0=t0, duration=duration)
end
# 1. Initial computation of `NFZ2`, a **list of times** 
# indexed by time line ("level"), where each time is initially defined as
# the supremum of times of **inactivated** `Removal`s at given level or 
# below. So the envelope increases monotonically with level.
# 2. The logic of the calculations in `compute_nofly` requires
# very careful attention!

@doc """
        CEvolution(SIR, Vector{AbstractIncident};
                LFE=AbstractIncident[], NFZ1=Real[], NFZ2=Real[], NFZ=Real[],
                size::Int=0)::CEvolution

This is the second way to construct a [`CEvolution`](@ref): 
using a `chronology` (a vector of [`AbstractIncident`](@ref)s).
### Example
```jldoctest CEvolution_setup
initial    = SIR(0.0, 2, 1, 0)
population = initial.n
infections = [NF(0,2,3), XI(0.2, 2, 3), I(0.7,1,2), P(0.5,1,2)]
removals   = [R(0.1, 1), KR(0.2, 3), R(0.1, 2)]
cremovals  = [C(0.0, 1)]
chronology = infections ∪ removals ∪ cremovals

ev = CEvolution(initial, chronology, NFZ1=[0.5])
ev.NFZ1 == Real[0.5]

# output
true
```
"""
function CEvolution(initial_state::SIR, chronology::Vector{AbstractIncident}; 
                    LFE=AbstractIncident[], NFZ1=Real[], NFZ2=Real[], NFZ=Real[], 
                    size::Int=0, t0::Real=-Inf, duration::Real=Inf)
        innovation = Innovation(initial_state.n,
                    AbstractInfection[z for z ∈ chronology if z isa AbstractInfection],
                    AbstractRemoval[z for z ∈ chronology if z isa AbstractRemoval && !(z isa CRemoval)],
                    CRemoval[z for z ∈ chronology if z isa CRemoval]
                    )
    return CEvolution(initial_state, innovation, LFE=LFE, NFZ1=NFZ1, NFZ2=NFZ2, NFZ=NFZ, 
                      size=size, t0=t0, duration=duration)
end

@doc """
    CEvolution(::SIR, ::AbstractInnovation; 
            LFE=AbstractIncident[], NFZ1=Real[], NFZ2=Real[], NFZ=Real[], size::Int=0)::CEvolution

This is the third way:
employing an [`Innovation`](@ref).
### Example
```jldoctest CEvolution_setup
initial    = SIR(0.0, 2, 1, 0)
population = initial.n
infections = [NF(0,2,3), XI(0.2, 2, 3), I(0.7,1,2), P(0.5,1,2)]
removals   = [R(0.1, 1), KR(0.2, 3), R(0.1, 2)]
cremovals  = [C(0.0, 1)]
chronology = infections ∪ removals ∪ cremovals

innov      = Innovation(population, infections, removals, cremovals) 
CEvolution(initial, innov)

# output
CEvolution(SIR₀.₀₀(2:1:0),
infections: AbstractInfection[𝒩₀.₀₀²⁻³,𝒳₀.₂₀²⁻³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   AbstractRemoval[ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒦₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₀₀¹]
chronology: AbstractIncident[𝒩₀.₀₀²⁻³,𝒞₀.₀₀¹,ℛ₀.₁₀¹,ℛ₀.₁₀²,𝒳₀.₂₀²⁻³,𝒦₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₀₀(2:0:1)]
history:    AbstractIncident[𝒞₀.₀₀¹])
```
"""
function CEvolution(initial_state::SIR, innovation::AbstractInnovation;
                    LFE=AbstractIncident[], NFZ1=Real[], NFZ2=Real[], NFZ=Real[], 
                    size::Int=0, t0::Real=-Inf, duration::Real=Inf)
    # Need to check population == sum of `initial_state` entries
    population          = innovation.population
    infections          = innovation.infections
    removals            = innovation.removals
    cremovals           = innovation.cremovals   
    chronology          = innovation.chronology
    trajectory, history = evolution(initial_state, innovation, conditioned=true)
    start               = create_start(trajectory[1], history)
    finis               = create_finis(trajectory[1], history)
    if t0 == -Inf
        t0 = minimum(z.t for z in chronology)
    end
    if duration == Inf
        duration = maximum(z.t for z in chronology) - t0
    end
        
    return new(population, size, deepcopy(infections), deepcopy(removals), deepcopy(cremovals),
               chronology, trajectory, history, initial_state, start, finis,
               LFE, NFZ1, NFZ2, NFZ,
               t0, duration)
end

end

# ### Innovation starts
"""
    AbstractInnovationStart

This abstract type holds information which can be generated by `rand`, and
then in turn can be combined with a `CEvolution` using `⋄` to generate
a proposal of a new `initial` state whose acceptance depends on whether
the `CEvolution` meets required conditions when started with the proposal.
"""
abstract type AbstractInnovationStart end

"""
    InnovationStart_IS{::Categorical{Real, Vector{Real}}, ::Int} <: AbstractInnovationStart
    
The `InnovationStart_IS` information is a proposal of a positive integer to be used for the infection field
for the `SIR` for the new initial state, accompanied by a specific `Categorical` distribution
to be used as prior to evaluate the proposal. Combined with a test
that the result leads to a valid `CEvolution`,
this carries out the equivalent of an independence sampler move (the acronym `_IS`
refers to "Independence Sampler").
### Example
```jldoctest
prior = Categorical(Real[0.8, 0.2])
InnovationStart_IS(prior, 1)

# output

InnovationStart_IS(Categorical{Real, Vector{Real}}(support=Base.OneTo(2), p=Real[0.8, 0.2]), 1)
```
"""
struct InnovationStart_IS <: AbstractInnovationStart
    prior    ::Categorical
    proposal ::Int

function InnovationStart_IS(prior::Categorical, proposal::Int)::InnovationStart_IS
   return new(prior, proposal)
end    

@doc """
    InnovationStart_IS(::Vector{Real}, ::Int)::InnovationStart_IS

Shortcut: supply the vector of probabilities
defining the required `Categorical` distribution.
### Example
```jldoctest; setup = :(using EpidemicsCFTP)
prob=Real[0.7, 0.3]
InnovationStart_IS(prob, 1)

# output

InnovationStart_IS(Categorical{Real, Vector{Real}}(support=Base.OneTo(2), p=Real[0.7, 0.3]), 1)
```
"""
function InnovationStart_IS(prob::Vector{<: Real}, proposal::Int)::InnovationStart_IS
   return new(Categorical(prob), proposal)
end
end

"""
    InnovationStart_RWM <: AbstractInnovationStart
    
The `InnovationStart_RWM` information is again
simply a specific `Categorical` distribution `prior`
to be used in constructing a new proposal for the initial state,
on range of integer values `1:nmax`.
However using `rand` on this generates a `shift` `±1` equiprobably
and uses a `Uniform(0,1)` `mark` to test whether to accept this `shift`,
according to a (simple) Random Walk Metropolis test.

Combined with a test
that the result leads to a valid `CEvolution`,
this carries out the equivalent of a
Random Walk Metropolis sampler move (the suffix `_RWM`
refers to Random Walk Metropolis Sampler!).
### Example
```jldoctest
prior = Categorical(Real[0.8, 0.2])
InnovationStart_RWM(prior, 0.5, 1)

# output

InnovationStart_RWM(Categorical{Real, Vector{Real}}(support=Base.OneTo(2), p=Real[0.8, 0.2]), 0.5, 1, 2)
```
"""
struct InnovationStart_RWM <: AbstractInnovationStart
    prior ::Categorical
    mark  ::Real
    shift ::Int
    nmax  ::Int

function InnovationStart_RWM(prior::Categorical, mark::Real, shift::Int)::InnovationStart_RWM
    return new(prior, mark, shift, ncategories(prior))
end    

@doc """
    InnovationStart_RWM(Vector{Real})::InnovationStart_RWM

Shortcut: supply the vector of probabilities
defining the required `Categorical` distribution
and (by default) .
### Example
```jldoctest; setup = :(using EpidemicsCFTP)
prob=Real[0.7, 0.3]
InnovationStart_RWM(prob, 0.5, 1)

# output

InnovationStart_RWM(Categorical{Real, Vector{Real}}(support=Base.OneTo(2), p=Real[0.7, 0.3]), 0.5, 1, 2)
```
"""
function InnovationStart_RWM(prob::Vector{<: Real}, mark::Real, shift::Int)::InnovationStart_RWM
   return new(Categorical(prob), mark, shift, length(prob))
end
end

