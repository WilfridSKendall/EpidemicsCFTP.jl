"""
This module implements a CFTP algorithm for epidemic S-I-R trajectories conditional on observation of all removals.
"""
module EpidemicsCFTP

loc     = dirname(dirname(pathof(EpidemicsCFTP)))
version = "$(read(Cmd(`git describe --tags`, dir=loc), String)[1:end-1])"
branch  = "$(read(Cmd(`git branch --show-current`, dir=loc), String)[1:end-1])"

# Imports
# -------
# The `Formatting` module is required in order to define `show` methods for the various types.
using Formatting
# Import `Distributions` module.
import Distributions

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

export evolution

export generate_innovation

export isearlier

export alter
export perpetuate

# Included files
# ==============
# Include types defined in this package.
include("Types.jl")

# Include subsidiary functions defined or extended in this package.
include("Functions.jl")

end

