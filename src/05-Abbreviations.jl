# Standard abbreviations for various `AbstractInfection`s
# -------------------------------------------------------
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
