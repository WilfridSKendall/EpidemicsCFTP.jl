# Standard abbreviations for various `AbstractInfection`s
# -------------------------------------------------------
"""
The sub-module `EpidemicsCFTP.abbreviations` provides simple abbreviations for [`AbstractIncident`](@ref)s,
at the cost of using one-, two- or three-letter capital abbreviations:

```
 AI = AbstractIncident;
AIF = AbstractInfection;   I = Infection; P = PInfection;
 NF = NoFlyInfection;     XI = ExpungedInfection;
AIR = AbstractRemoval;     R = Removal;   C = CRemoval;
 KI = KilledInfection;    KR = KilledRemoval;
 OI = OperativeInfection; NR = NonOperativeInfection;
 OR = OperativeRemoval;   NR = NonOperativeRemoval;
 IM = InfectionMarker;    RM = RemovalMarker;
```

Make all abbreviations available by `using EpidemicsCFTP.abbreviations`.
Alternatively `import` only some selected abbreviations from `EpidemicsCFTP.abbreviations`,
for example as in the following.
```julia
import EpidemicsCFTP.abbreviations: I
```
"""
module abbreviations

import EpidemicsCFTP: AbstractIncident,
    AbstractInfection,  Infection,  PInfection, NoFlyInfection,     ExpungedInfection,
    AbstractRemoval,    Removal,    CRemoval,   KilledInfection,    KilledRemoval,
    OperativeInfection, NonOperativeInfection,
    OperativeRemoval,   NonOperativeRemoval,
    InfectionMarker,    RemovalMarker

export AI, 
    AIF, I,  P, NF, XI,
    AIR, R,  C, KI, KR,
    OI, NO, OR, NR, 
    IM, RM
    
 AI = AbstractIncident;
AIF = AbstractInfection;   I = Infection; P = PInfection;
 NF = NoFlyInfection;     XI = ExpungedInfection;
AIR = AbstractRemoval;     R = Removal;   C = CRemoval;
 KI = KilledInfection;    KR = KilledRemoval;
 OI = OperativeInfection; NR = NonOperativeInfection;
 OR = OperativeRemoval;   NR = NonOperativeRemoval;
 IM = InfectionMarker;    RM = RemovalMarker;

end
