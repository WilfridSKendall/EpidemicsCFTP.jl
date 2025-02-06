# # Various tests
BANNER = 41

# Initial condition and duration
duration    = 5.0
initial     = SIR(0.0, 4, 1, 0) 

# ## Original appendix for `test.qmd`
# We now add some structures used later for defining and testing
# `Innovation`s and `AbstractEvolution`s.
infections  = AIF[I(2t-1, t, t+1) for t ∈ [1,2]] ∪ AIF[I(0,3,4), I(2,4,5)]
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


# ### Substitution of various removals
# The current task is to check removal of all inactive `Removal`s and application of
# functions `inactive_removals` and `resulting_cremovals` from `EpidemicsCFTP`.
#
# The first test set considers `ev1_1`, obtained by removing all inactivated `Removal`s.
# History and trajectory should not change, while the chronology should be obtained by 
# subtracting inactive `Removal`s.
iv1_1   = Innovation(initial.n, infections, R[], cremovals)
ev1_1   = CEvolution(initial, iv1_1)

begin ; title = "EpidemicsCFTP: Removing Removals"
    @testset "$(rpad(title, BANNER))" begin
        @test ev1_1.trajectory == ev1.trajectory
        @test ev1_1.history    == ev1.history
        @test ev1_1.chronology == setdiff(ev1.chronology, ev1.removals)
    end
end ;

# Now consider `ev1_2`, obtained by using `EpidemicsCFTP.inactive_removals`
# to add in only the inactive removals from the candidate `Innovation` `iv2c` 
# (not activated by the trajectory of `ev1` equivalently `ev1_1`).


infections2 = AIF[I(2t-1.5, t, t+1) for t ∈ [1,2]] ∪ AIF[I(0,3,4), I(2,4,5)]
removals2   = R[R(0.5,5), R(2.5,5), R(2.6,1), R(3.6,1), R(3.9,5), R(4.6,2)]
cremovals2  = C[C(2t, 2t) for t ∈ [1,2]] 


iv2c  = Innovation(initial.n, infections2, removals2, cremovals2)
iv1_2 = Innovation(initial.n, iv1_1.infections, 
    EpidemicsCFTP.inactive_removals(ev1, iv2c), iv1_1.cremovals)
ev1_2 = CEvolution(initial, iv1_2)

begin ; title = "EpidemicsCFTP: Inserting Removals"
    early_removals = [z for z ∈ ev1_2.chronology if z isa AIR && z < ev1_2.start[z.target]]
    late_removals  = [z for z ∈ ev1_2.chronology if z isa AIR && z > ev1_2.finis[z.target]]
    @testset "$(rpad(title, BANNER))" begin
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
begin ; title = "EpidemicsCFTP: Modifying CRemovals"
    @testset "$(rpad(title, BANNER))" begin
        @test ev1_3.trajectory == ev1.trajectory
        @test ev1_3.infections == ev1.infections
        @test [z for z ∈ ev1_3.chronology if z isa R]  == early_removals
        @test [z for z ∈ ev1_3.chronology if z isa KR] == late_removals
        @test ev1_3.cremovals  == C[C(2,2), C(4,2)] 
    end
end ;

# ### Testing the laziest feasible epidemic

laziest_feasible_history =
    EpidemicsCFTP.laziest_feasible_evolution(duration, ev1_3, iv2c)
laziest_feasible_new_infections = AIF[z for z ∈ laziest_feasible_history ∩ iv2c.infections]
perpetuated_infections       = P[PInfection(z) for z ∈ laziest_feasible_history ∩ ev1_3.infections]
other_older_infections       = setdiff(ev1_3.infections, AIF[z for z ∈ laziest_feasible_history if z isa AIF])
iv1_4 = Innovation(initial.n, perpetuated_infections ∪ laziest_feasible_new_infections ∪
                        other_older_infections, ev1_3.removals, ev1_3.cremovals)
ev1_4 = CEvolution(initial, iv1_4, LFE=laziest_feasible_history)
begin ; title = "EpidemicsCFTP: Laziest feasible evolution"
    LFE_target = [P(1.0,1,2), C(2.0,2), C(4.0,2)]
    @testset "$(rpad(title, BANNER))" begin
        @test ev1_4.LFE == LFE_target
    end
end ;
