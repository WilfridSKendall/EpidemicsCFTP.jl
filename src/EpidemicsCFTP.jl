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
# # The functions `isless` and `rand` are overloaded in  `03-Methods.jl`!
import Base: isless, rand
# # The `Format` module is required in order to define `show` methods for the various types.
using Format
# # Functions from the `Distributions` module are required in order to simulate new `Innovation`s.
import Distributions
import Distributions: DiscreteUniform, Uniform, Poisson
# # The `DataFrames` module is required in order to provide placeholders for trajectory flows.
import DataFrames
# # We need `AbstractRNG` and `SamplerTrivial` from the  `Random` module 
# in order to produce implementations of `rand` for sampling various random objects.
import Random
import Random: SamplerTrivial, rand, AbstractRNG

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

export AbstractInnovationStart, InnovationStart_IS

# # Defined in `02-methods.jl`
export evolution, evolution_history
export extremal_evolution

export alter

export ⪯, ≃, ⋄, ▷

# # Defined in `04-exceptions.jl`
export BadIncident, MissedCRemoval, EmployedRemoval
export BadLFE, EmptyLFE, NonMinimalLFE
export BadNFZ, ExpungedInfectionGivesValidTrajectory

# # Sub-module defined in `05-Abbreviations.jl`
# This is _not_ explicitly exported: import or use it 
# as `EpidemicsCFTP.abbreviations`.

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

# # Include abbreviations defined in a sub-package.
include("05-Abbreviations.jl")

# # We use the `.abbreviations` module internally for ease of reference.
using .abbreviations

end

