import EpidemicsCFTP: date, version
println("EpidemicsCFTP version $version, compiled on $date")

import InteractiveUtils: subtypes
using EpidemicsCFTP
using Test

### Useful function for returning all concrete subtypes
# -----------------------------------------------------
function allconcretesubtypes(T)
    Tl = subtypes(T)
    if isempty(Tl)
        return [T]
    else
        return ∪([allconcretesubtypes(S) for S ∈ Tl]...)
    end
end

### Useful constants
# ------------------
AI  = AbstractIncident;
AIF = AbstractInfection;  I = Infection; P = PInfection; 
NF  = NoFlyInfection;    XI = ExpungedInfection;
AIR = AbstractRemoval;    R = Removal;   C = CRemoval;   
KI  = KilledInfection;   KR = KilledRemoval;
IM  = InfectionMarker;   RM = RemovalMarker;



    
include("01-Types.jl")
include("02-Methods.jl")
include("03-Various.jl")

