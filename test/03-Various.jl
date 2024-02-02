# # Various tests
# The following unit tests should eventually be incorporated in `EpidemicsCFTP/test`
# test files. To aid concise expression, 
# we define some abbreviations.
AI = AbstractInfection; I = Infection; P = PInfection; NF  = NoFlyInfection; XI = ExpungedInfection;
AR = AbstractRemoval;   R = Removal;   C = CRemoval;   KI = KilledInfection; KR = KilledRemoval;

# Initial condition and duration
duration    = 5.0
initial     = SIR(0.0, 4, 1, 0) 

# ## Original appendix for `test.qmd`
# We now add some structures used later for defining and testing
# `Innovation`s and `AbstractEvolution`s.
infections  = AI[I(2t-1, t, t+1) for t ∈ [1,2]] ∪ AI[I(0,3,4), I(2,4,5)]
uremovals   = R[R(2t, t) for t ∈ [1,2]] ∪ [R(1,5), R(3,5), R(4.9,5)]
removals    = R[R(1,5), R(3,5), R(4.9,5)]
cremovals   = C[C(2t, t) for t ∈ [1,2]] 
trajectory  = SIR[SIR(0,4,1,0), SIR(1,3,2,0), SIR(2,3,1,1), SIR(3,2,2,1), SIR(4,2,1,2)]
uhistory    = [I(1,1,2), R(2,1), I(3,2,3), R(4,2)]
history     = [I(1,1,2), C(2,1), I(3,2,3), C(4,2)]

uiv1  = Innovation(initial.n, infections, uremovals)
uev1  = Evolution(initial, uiv1)
iv1   = Innovation(initial.n, infections, removals, cremovals)
ev1   = CEvolution(initial, iv1)


# ### Testing unconditioned and conditioned versions of `AbstractEvolution`
# These tests are intended to check that fields are correctly filled.
begin ;  title = string(Evolution, " (more)")
    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
        @test uev1.infections  == sort(infections)
        @test uev1.removals    == sort(uremovals)
        @test uev1.chronology  == sort(infections ∪ uremovals)
        @test uev1.trajectory  == trajectory
        @test uev1.history     == uhistory
    end
end

begin ; title = string(CEvolution, " (more)")
    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
        @test sort(uremovals) == [R(z) for z ∈ sort(removals ∪ cremovals)]
        @test ev1.infections   == sort(infections)
        @test ev1.removals     == sort(removals)
        @test ev1.chronology   == sort(infections ∪ removals ∪ cremovals)
        @test ev1.trajectory   == trajectory
        @test ev1.history      == history
    end ;
end ;

# ### Substitution of various removals
# The current task is to check removal of all inactive `Removal`s and application of
# functions `inactive_removals` and `resulting_cremovals` from `EpidemicsCFTP`.
#
# The first test set considers `ev1_1`, obtained by removing all inactivated `Removal`s.
# History and trajectory should not change, while the chronology should be obtained by 
# subtracting inactive `Removal`s.
iv1_1   = Innovation(initial.n, infections, R[], cremovals)
ev1_1   = CEvolution(initial, iv1_1)

begin ; title = "Removing Removals"
    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
        @test ev1_1.trajectory == ev1.trajectory
        @test ev1_1.history    == ev1.history
        @test ev1_1.chronology == setdiff(ev1.chronology, ev1.removals)
    end
end ;

# Now consider `ev1_2`, obtained by using `EpidemicsCFTP.inactive_removals`
# to add in only the inactive removals from the candidate `Innovation` `iv2c` 
# (not activated by the trajectory of `ev1` equivalently `ev1_1`).


infections2 = AI[I(2t-1.5, t, t+1) for t ∈ [1,2]] ∪ AI[I(0,3,4), I(2,4,5)]
removals2   = R[R(0.5,5), R(2.5,5), R(2.6,1), R(3.6,1), R(3.9,5), R(4.6,2)]
cremovals2  = C[C(2t, 2t) for t ∈ [1,2]] 


iv2c  = Innovation(initial.n, infections2, removals2, cremovals2)
iv1_2 = Innovation(initial.n, iv1_1.infections, 
    EpidemicsCFTP.inactive_removals(ev1, iv2c), iv1_1.cremovals)
ev1_2 = CEvolution(initial, iv1_2)

begin ; title = "Inserting Removals"
    early_removals = [z for z ∈ ev1_2.chronology if z isa AR && z < ev1_2.start[z.target]]
    late_removals  = [z for z ∈ ev1_2.chronology if z isa AR && z > ev1_2.finis[z.target]]
    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
        @test ev1_2.trajectory == ev1.trajectory
        @test [z for z ∈ ev1_2.chronology if z isa R]  == early_removals
        @test [z for z ∈ ev1_2.chronology if z isa KR] == late_removals
    end
end ;

# Consider the effect of `EpidemicsCFTP.resulting_cremovals`.
iv1_3 = Innovation(initial.n, iv1_2.infections, iv1_2.removals, 
    EpidemicsCFTP.resulting_cremovals(ev1_2, iv2c))
#ev1_3 = CEvolution(initial, iv1_3, envelope0=envelope0, envelope=envelope)
ev1_3 = CEvolution(initial, iv1_3)
begin ; title = "Modifying CRemovals"
    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
        @test ev1_3.trajectory == ev1.trajectory
        @test ev1_3.infections == ev1.infections
        @test [z for z ∈ ev1_3.chronology if z isa R]  == early_removals
        @test [z for z ∈ ev1_3.chronology if z isa KR] == late_removals
        @test ev1_3.cremovals  == C[C(2,2), C(4,2)] 
    end
end ;

# ### Testing the last feasible epidemic

last_feasible_history =
    EpidemicsCFTP.last_feasible_evolution(duration, ev1_3, iv2c)
last_feasible_new_infections = AI[z for z ∈ last_feasible_history ∩ iv2c.infections]
perpetuated_infections       = P[PInfection(z) for z ∈ last_feasible_history ∩ ev1_3.infections]
other_older_infections       = setdiff(ev1_3.infections, AI[z for z ∈ last_feasible_history if z isa AI])
iv1_4 = Innovation(initial.n, perpetuated_infections ∪ last_feasible_new_infections ∪
                        other_older_infections, ev1_3.removals, ev1_3.cremovals)
ev1_4 = CEvolution(initial, iv1_4, LFE=last_feasible_history)
begin ; title = "Last feasible evolution"
    LFE_target = [P(1.0,1,2), C(2.0,2), C(4.0,2)]
    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
        @test ev1_4.LFE == LFE_target
    end
end ;

# ## Some tests extracted from content of `test.qmd`.
# ### Basic tests
# We now derive some structures relating to a different `Innovation` and `Evolution`/`CEvolution`.
xuiv1 = Innovation(initial.n, 
    I[I(2t-1, t, t+1) for t ∈ [1,2]] ∪ AI[I(0,3,4), I(2,4,5)], 
    [R(2t, t) for t ∈ [1,2]] ∪ [R(1,5), R(3,5), R(4,5)])
xuev1 = Evolution(initial, xuiv1)

xiv1 = Innovation(initial.n, xuev1.infections, 
        R[z for z in setdiff(xuev1.removals, xuev1.history)], 
        C[C(z) for z in xuev1.removals ∩ xuev1.history])
xev1 = CEvolution(initial, xiv1)

begin ; title = "Expected evolution (I)"
    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
        @test xiv1.infections  == [I(0.0,3,4), I(1.0,1,2), I(2.0,4,5), I(3.0,2,3)]
        @test xiv1.removals    == [R(1.0,5), R(3.0,5), R(4.0,5)]
        @test xiv1.cremovals   == [C(2.0,1), C(4.0,2)]
        
        @test xev1.infections  == xiv1.infections
        @test xev1.cremovals   == xiv1.cremovals
        @test xev1.removals    == xiv1.removals
        
        @test xev1.trajectory  == SIR[SIR(0.0,4,1,0,5),SIR(1.0,3,2,0,5),SIR(2.0,3,1,1,5),SIR(3.0,2,2,1,5),SIR(4.0,2,1,2,5)]
        @test xev1.history     == [I(1.0,1,2), C(2.0,1), I(3.0,2,3), C(4.0,2)]
        
        @test length(ev1.LFE)  == 0
        @test length(ev1.NFZ1) == 0
        @test length(ev1.NFZ2) == 0
        @test length(ev1.NFZ3) == 0
    end
end ;

# ### Intermediate stages
xiv2c = Innovation(initial.n, 
    AI[I(0.75,1,2), I(1.5,1,2), I(0.8,3,4), I(1.5,2,3), I(2.5,1,2), I(3.3,3,4), 
        I(3.6,4,5), I(3.9,4,5), I(4.5,1,3), I(4.4,3,4)], 
    R[R(0.5,2), R(2,3), R(1.2,4), R(3.3,1), R(4.5,5), R(4.8,1)], 
    C[C(2, 2), C(4,5)])
xev2  = CEvolution(xev1, xiv2c)

xiv1_1 = Innovation(initial.n, xev1.infections, R[], xev1.cremovals)
xev1_1 = CEvolution(initial, xiv1_1)

xiv1_2 = Innovation(initial.n, xev1.infections, 
    EpidemicsCFTP.inactive_removals(xev1, xiv2c), xev1.cremovals)
xev1_2 = CEvolution(initial, xiv1_2)

xiv1_3 = Innovation(initial.n, xev1.infections, xev1_2.removals, 
    EpidemicsCFTP.resulting_cremovals(xev1, xiv2c))
xev1_3 = CEvolution(initial, xiv1_3)


# Notice that use of `ev1_1` or `ev1_2` rather than `ev1` still yields
# the same `CRemoval`s.

begin ; title = "Expected evolution (II)"
    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
        @test EpidemicsCFTP.resulting_cremovals(xev1, xiv2c) == 
            EpidemicsCFTP.resulting_cremovals(xev1_1, xiv2c)
        @test EpidemicsCFTP.resulting_cremovals(xev1, xiv2c) == 
            EpidemicsCFTP.resulting_cremovals(xev1_2, xiv2c)
        @test xev2.LFE == EpidemicsCFTP.last_feasible_evolution(duration, xev1_3, xiv2c)
    end
end ;

# ### Finally compute the "no-fly" zone and check resulting evolution
last_feasible_new_infections = AI[z for z ∈ xev2.LFE ∩ iv2c.infections]
perpetuated_infections       = P[PInfection(z) for z ∈ xev2.LFE ∩ ev1_3.infections]
other_older_infections       = setdiff(xev1_3.infections, AI[z for z ∈ xev2.LFE if z isa AI])
xiv1_4 = Innovation(initial.n, perpetuated_infections ∪ last_feasible_new_infections ∪ 
                        other_older_infections, xev1_3.removals, xev1_3.cremovals)
xev1_4 = CEvolution(initial, xiv1_4, LFE=xev2.LFE)

max_removal_time = repeat([-Inf], xev1_4.initial.n)
for z ∈ [z for z ∈ xev1_4.removals if z < xev1_4.finis[z.target]]
    max_removal_time[z.target] = max(max_removal_time[z.target], z.t)
end
nofly_envelope = accumulate(max, max_removal_time)

# # *** DEBUG
#println(sprint(show, MIME("text/plain"), xev2.infections))
#println(sprint(show, MIME("text/plain"), [I(0.75,1,2), I(0.8,3,4), I(1.5,1,2), XI(1.5,2,3), KI(2.5,1,2), 
#                                    P(3.0,2,3), XI(3.3,3,4), I(3.6,4,5), NF(3.9,4,5), 
#                                    I(4.4,3,4), KI(4.5,1,3)]))
#
#begin ; title = "Expected evolution (III)"
#    @testset "EpidemicsCFTP: $(rpad(title, 23))" begin
#    @test xev2.NFZ2       == nofly_envelope
#    @test xev2.infections == [I(0.75,1,2), I(0.8,3,4), I(1.5,1,2), XI(1.5,2,3), KI(2.5,1,2), 
#                                    P(3.0,2,3), XI(3.3,3,4), I(3.6,4,5), NF(3.9,4,5), 
#                                    I(4.4,3,4), KI(4.5,1,3)]
#    @test xev2.removals   == [R(0.5,2), R(1.2,4), R(2,3), KR(3.3,1), R(4.5,5), KR(4.8,1)]
#    @test xev2.cremovals  == [C(2,2), C(4,2)]
#    @test xev2.LFE        == [I(1.5,1,2), C(2,2), I(3,2,3), C(4,2)]
#    @test xev2.NFZ1       == [-Inf, 0.5, 2.0, 1.2, 4.5]
#    @test xev2.NFZ2       == [-Inf, 0.5, 2.0, 2.0, 4.5]
#    @test xev2.NFZ3       == [-Inf, 0.5, 2.0, 3.9, 4.5]
#
#    @test xev1_2.removals  == xev2.removals
#    @test xev1_3.cremovals == xev1_4.cremovals == xev2.cremovals
#    @test xev1.LFE   == AbstractIncident[]
#    @test xev1_1.LFE == AbstractIncident[]
#    @test xev1_2.LFE == AbstractIncident[]
#    @test xev1_3.LFE == AbstractIncident[]
#    @test xev1_4.LFE == AbstractIncident[I(1.5,1,2), C(2.0,2), I(3.0,2,3), C(4.0,2)]
#    @test xev2.LFE   == AbstractIncident[I(1.5,1,2), C(2.0,2), I(3.0,2,3), C(4.0,2)]
#    end
#end ;
