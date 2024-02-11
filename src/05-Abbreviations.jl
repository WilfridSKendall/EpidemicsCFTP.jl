# Standard abbreviations for various `AbstractInfection`s
# -------------------------------------------------------
"""
The module `abbreviations` provides simple abbreviations for `AbstractIncident`s,
at the cost of using one-, two- or three-letter capital abbreviations:

```
AI  = AbstractIncident;
AIF = AbstractInfection;  I = Infection; P = PInfection;
 NF = NoFlyInfection;    XI = ExpungedInfection;
AIR = AbstractRemoval;    R = Removal;   C = CRemoval;
 KI = KilledInfection;   KR = KilledRemoval;
IM  = InfectionMarker;   RM = RemovalMarker;
```

Make all abbreviationsa vailable by `using EpidemicsCFTP.abbreviations`,
or `import` only selected abbreviations from `EpidemicsCFTP.abbreviations`.
"""
module abbreviations

import EpidemicsCFTP: AbstractIncident,
    AbstractInfection,  Infection,  PInfection, NoFlyInfection,     ExpungedInfection,
    AbstractRemoval,    Removal,    CRemoval,   KilledInfection,    KilledRemoval,
    InfectionMarker,    RemovalMarker

export AI, 
    AIF, I, P, NF, XI,
    AIR, R, C, KI, KR,
    IM, RM
    
AI  = AbstractIncident;
AIF = AbstractInfection;  I = Infection; P = PInfection;
 NF = NoFlyInfection;    XI = ExpungedInfection;
AIR = AbstractRemoval;    R = Removal;   C = CRemoval;
 KI = KilledInfection;   KR = KilledRemoval;
IM  = InfectionMarker;   RM = RemovalMarker;

end
