import InteractiveUtils: subtypes
using EpidemicsCFTP
using Test

# Useful function for returning all concrete subtypes
function allconcretesubtypes(T)
    Tl = subtypes(T)
    if isempty(Tl)
        return [T]
    else
        return union([allconcretesubtypes(S) for S in Tl]...)
    end
end

    
include("Types.jl")
include("Methods.jl")

