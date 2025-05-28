# Exceptions
# ----------
"""

Reports misuse of an incident. Doctests are supplied below for 
specific sub-types.
"""
abstract type BadIncident <: Exception end

"""
Reports problems with an `LFE` as produced by 
[`laziest_feasible_evolution`](@ref)
(typically arising as a field of a 
[`CEvolution`](@ref)).
"""
abstract type BadLFE <: Exception end

"""
Report problems with an `NFZ` 
(typically arising as a field of a 
[`CEvolution`](@ref)).
"""
abstract type BadNFZ <: Exception end

# ### Specific `BadIncident` exceptions
"""
Raised when a [`CRemoval`](@ref) is missed by
`evolution`.

### Example
```jldoctest
population = 3 
infections = [I(0.7,1,2), P(0.5,1,2)] 
removals   = [R(0.2, 3), R(0.1, 2)] 
cremovals  = [C(0.0, 1), C(0.05, 3)] 
innov      = Innovation(population, infections, removals, cremovals) 
initial    = SIR(0.0, 2, 1, 0)
CEvolution(initial, innov)

# output
ERROR: [MissedCRemoval] The (conditioned) evolution failed to employ CRemoval(0.05, 3)
```
"""
struct MissedCRemoval <: BadIncident
    incident ::AbstractIncident
end


"""
Raised when a [`Removal`](@ref) is not missed by
[`evolution`}(@ref).

### Example
```jldoctest
population = 3 
infections = [I(0.7,1,2), P(0.5,1,2)] 
removals   = [R(0.05, 3), R(0.2, 1), R(0.1, 2)] 
cremovals  = [C(0.5, 1)] 
innov      = Innovation(population, infections, removals, cremovals) 
initial    = SIR(0.0, 2, 1, 0)
CEvolution(initial, innov)

# output
ERROR: [EmployedRemoval] The (conditioned) evolution wrongly employed Removal(0.2, 1)
```
"""
struct EmployedRemoval <: BadIncident
    incident ::AbstractIncident
end

# ### Specific `BadLFE` and `BadNFZ` exceptions
"""
Reports a non-minimal `LFE`.
"""
struct NonMinimalLFE <: Exception
    evolution ::AbstractEvolution
end


"""
Reports an empty `LFE`.
"""
struct EmptyLFE <: Exception
    ev ::AbstractEvolution
end



"""
Reports a faulty `NFZ`.
"""
struct ExpungedInfectionGivesValidTrajectory <: BadNFZ
    ev ::CEvolution
    z  ::ExpungedInfection
end


# ### Display of `Exception`s based on `BadIncident`
"""
Prints a `BadIncident` exception.
Sub-types of this exception are:
[`EmployedRemoval`](@ref) and [`MissedCRemoval`](@ref), typically raised respectively when a 
conditioned evolution uses a [`Removal`](@ref) which _is_ _not_ conditioned to appear in the trajectory,
or doesn't use a [`CRemoval`](@ref) which _is_ conditioned to appear in the trajectory.
"""
function Base.show(io::IO, e::BadIncident)
    print(io, "[$(typeof(e))] The (conditioned) evolution failed to employ $(e.incident)")
end

"""
Prints a `MissedCRemoval` exception.
"""
function Base.show(io::IO, e::MissedCRemoval)
    print(io, "[$(typeof(e))] The (conditioned) evolution failed to employ $(e.incident)")
end

"""
Prints a `EmployedRemoval` exception.
"""
function Base.show(io::IO, e::EmployedRemoval)
    print(io, "[$(typeof(e))] The (conditioned) evolution wrongly employed $(e.incident)")
end



# ### Display of `Exception`s based on `BadLFE`
"""
Prints a `BadLFE` exception.
"""
function Base.show(io::IO, e::BadLFE)
    print(io, "[$(typeof(e))] The following LFE is faulty:\n\t$(e.ev)")
end




# ### Display of `Exception`s based on `BadNFZ`
"""
Prints a `BadNFZ` exception.
"""
function Base.show(io::IO, e::BadNFZ)
    print(io, "[$(typeof(e))] The following NFZ is faulty at $(e.z):\n\t$(e.ev.NFZ)")
end
