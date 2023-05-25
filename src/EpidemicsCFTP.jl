"""
This module implements a CFTP algorithm for epidemic S-I-R trajectories conditional on observation of all removals.

Note that this is a re-working of original version!
"""
module EpidemicsCFTP

# Exports
# =======
# These functions can be called without qualifications.
export AbstractTimedOccurrence
export AbstractIncident
export AbstractRemoval
export AbstractInfection
export AbstractInnovation

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

