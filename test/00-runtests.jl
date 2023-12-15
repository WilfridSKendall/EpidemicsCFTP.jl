import EpidemicsCFTP: date, version
println("EpidemicsCFTP version $version, compiled on $date")

import InteractiveUtils: subtypes
using EpidemicsCFTP
using Test

# Useful function for returning all concrete subtypes
function allconcretesubtypes(T)
    Tl = subtypes(T)
    if isempty(Tl)
        return [T]
    else
        return ∪([allconcretesubtypes(S) for S ∈ Tl]...)
    end
end

    
include("01-Types.jl")
include("02-Methods.jl")

