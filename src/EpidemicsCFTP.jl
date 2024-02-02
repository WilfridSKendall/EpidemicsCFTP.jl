"""
Implements a CFTP algorithm for epidemic `S-I-R` trajectories conditional on all removal times.
"""
module EpidemicsCFTP

loc     = dirname(dirname(pathof(EpidemicsCFTP)))
version = "$(read(Cmd(`git describe --tags`, dir=loc), String)[1:end-1])"
branch  = "$(read(Cmd(`git branch --show-current`, dir=loc), String)[1:end-1])"
date    = replace(split(read(Cmd(`git log -1`, dir=loc), String), "\n")[3], 
                  "Date:   " => "", " +0000" => "")
summary = "EpidemicsCFTP version $version, checked in on $date"

# # Imports
# # -------
# # The `Formatting` module is required in order to define `show` methods for the various types.
using Formatting
# # The `Distributions` module is required in order to simulate new `Innovation`s.
import Distributions
# # The `DataFrames` module is required in order to provide placeholders for trajectory flows.
import DataFrames
# # Exports
# # =======
# # These entities can be invoked without qualification by parent module `EpidemicsCFTP`.

# # Defined in `01-types.jl`
export AbstractTimedOccurrence
export AbstractIncident, AbstractRemoval, AbstractInfection

export OperativeRemoval, NonOperativeRemoval
export Removal, CRemoval
export KilledRemoval, RemovalMarker

export OperativeInfection, NonOperativeInfection
export Infection, PInfection
export KilledInfection, NoFlyInfection, ExpungedInfection, InfectionMarker

export SIR

export AbstractEnvironment
export AbstractInnovation, AbstractEvolution
export Innovation, Evolution, CEvolution

# # Defined in `02-methods.jl`
export evolution, evolution_history

export generate_innovation

export alter
# # Defined in `04-exceptions.jl`

export BadIncident, MissedCRemoval, EmployedRemoval

# # Note also that `isless` is overloaded in `Methods.jl`!
import Base: isless

# # Included files
# # ==============
# # Include types defined in this package.
include("01-Types.jl")
 
# # Include general methods defined in this package.
include("02-Methods.jl")

# # Include subsidiary display methods extended in this package.
include("03-Methods-show.jl")

# # Include exceptions defined in this package.
include("04-Exceptions.jl")

end

