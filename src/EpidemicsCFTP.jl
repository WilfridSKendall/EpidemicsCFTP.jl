"""
This module implements a CFTP algorithm for epidemic S-I-R trajectories conditional on observation of all removals.

Note that this is a re-working of original version!
"""
module EpidemicsCFTP

# Exports
# =======
# These functions can be called without qualifications.
export AbstractIncident
export AbstractRemoval
export Removal
export CRemoval

# Included files
# ==============
# Include types defined in this package.
include("Types.jl")

# Include subsidiary functions defined or extended in this package.
include("Functions.jl")

end

