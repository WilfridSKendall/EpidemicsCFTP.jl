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
export AbstractIncident, AbstractRemoval, AbstractInfection, OperativeInfection, NonOperativeInfection
export Removal, CRemoval, Infection, PInfection
export KilledInfection, NoFlyInfection, CancelledInfection
export SIR

export AbstractInnovation, AbstractEvolution
export Innovation, Evolution, CEvolution

export evolution, generate_innovation

export isearlier

export alter, perpetuate

export BadIncident, MissedCRemoval, EmployedRemoval

# Included files
# ==============
# Include types defined in this package.
include("Types.jl")

# Include subsidiary functions defined or extended in this package.
include("Functions.jl")

end

