"""
This module implements a CFTP algorithm for epidemic S-I-R trajectories conditional on observation of all removals.

Note that this is a re-working of original version!
"""
module EpidemicsCFTP

# Exports
# =======
# These entities can be invoked without qualification by parent module `EpidemicsCFTP`.
export AbstractTimedOccurrence
export AbstractMarker
export AbstractIncident
export AbstractRemoval
export AbstractInfection
export AbstractInnovation

export InitialRemoved
export InitialInfected
export InitialSusceptible
export MarkerRemovalA
export MarkerInfectionA
export MarkerRemovalB
export MarkerInfectionB
export ContinuingRemoved
export ContinuingInfected
export ContinuingSusceptible

export Removal
export CRemoval

export Infection
export PInfection

export Innovation
export SIR

export chronology
export evolution_recurse!

export isearlier

# Included files
# ==============
# Include types defined in this package.
include("Types.jl")

# Include subsidiary functions defined or extended in this package.
include("Functions.jl")

end

