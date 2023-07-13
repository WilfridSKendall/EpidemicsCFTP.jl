"""
This module implements a CFTP algorithm for epidemic S-I-R trajectories conditional on observation of all removals.

Note that this is a re-working of original version!
"""
module EpidemicsCFTP

# Other modules
# -------------
# The `Formatting` module is required in order to define `show` methods for the various types.
using Formatting

# Exports
# =======
# These entities can be invoked without qualification by parent module `EpidemicsCFTP`.
export AbstractTimedOccurrence

export AbstractIncident
export AbstractRemoval
export AbstractInfection
export AbstractInnovation

export AbstractMarker
export AbstractSusceptibleMarker
export AbstractInfectionMarker
export AbstractRemovalMarker

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

export evolution_recurse! # Deprecated
export evolution

export isearlier

export resample
export perpetuate

# Included files
# ==============
# Include types defined in this package.
include("Types.jl")

# Include subsidiary functions defined or extended in this package.
include("Functions.jl")

end

