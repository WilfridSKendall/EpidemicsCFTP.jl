"""
Implements a CFTP algorithm for epidemic S-I-R trajectories conditional on all removal times.
"""
module EpidemicsCFTP

loc     = dirname(dirname(pathof(EpidemicsCFTP)))
version = "$(read(Cmd(`git describe --tags`, dir=loc), String)[1:end-1])"
branch  = "$(read(Cmd(`git branch --show-current`, dir=loc), String)[1:end-1])"
date    = replace(split(read(Cmd(`git log -1`), String), "\n")[3], "Date:   " => "", " +0000" => "")

# # Imports
# # -------
# # The `Formatting` module is required in order to define `show` methods for the various types.
using Formatting
# # Import `Distributions` module.
import Distributions

# # Exports
# # =======
# # These entities can be invoked without qualification by parent module `EpidemicsCFTP`.

export AbstractTimedOccurrence
export AbstractIncident, AbstractRemoval, AbstractInfection

export OperativeRemoval, NonOperativeRemoval
export Removal, CRemoval
export KilledRemoval

export OperativeInfection, NonOperativeInfection
export Infection, PInfection
export KilledInfection, NoFlyInfection, ExpungedInfection

export SIR

export AbstractEnvironment
export AbstractInnovation, AbstractEvolution
export Innovation, Evolution, CEvolution

export evolution, generate_innovation

export isearlier

export alter

export BadIncident, MissedCRemoval, EmployedRemoval

# # Included files
# # ==============
# # Include types defined in this package.
include("Types.jl")

# # Include methods defined in this package.
include("Methods.jl")

# # Include subsidiary display methods extended in this package.
include("Methods-display.jl")

end

