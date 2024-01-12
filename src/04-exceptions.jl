# # Exceptions
# # ----------

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

# ### Display of `Exception` `BadIncident`
"""
    Base.show(io::IO, e::BadIncident)
    
Printing a `BadIncident` exception.
Sub-types of this exception are:
[`EmployedRemoval`](@ref) and [`MissedCRemoval`](@ref), raised respectively when a 
conditioned evolution uses a [`Removal`](@ref) which _is_ _not_ conditioned to appear in the trajectory,
or doesn't use a [`CRemoval`](@ref) which _is_ conditioned to appear in the trajectory.
See these types for doctests.
"""
function Base.show(io::IO, e::BadIncident)
    print(io, "[$(typeof(e))] The (conditioned) evolution misused $(e.incident)")
end
