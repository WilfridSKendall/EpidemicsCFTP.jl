"""
This module implements a CFTP algorithm for epidemic S-I-R trajectories conditional on observation of all removals.

This is version $(EpidemicsCFTP.version) on branch $(EpidemicsCFTP.branch).

Note that this is a re-working of original version!
"""
module EpidemicsCFTP

# The current version is `2.2.170` on branch `main`.
version = "$(read(`git describe --tags`, String)[1:end-1])"
branch  = "$(read(`git branch --show-current`, String)[1:end-1])"

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
export AbstractEvolution

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
export Evolution
export CEvolution
export SIR

# export evolution_recurse! # Now in deprecated.jl, no longer compiled
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

