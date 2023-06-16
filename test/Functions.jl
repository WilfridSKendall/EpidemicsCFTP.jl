# Tests for `EpidemicsCFTP`

## Testing `isearlier`
# =================================
@testset "EpidemicsCFTP: isearlier     " begin
    @test  isearlier(Removal(0.10, 2),      Removal(0.5, 3))
    @test !isearlier(Removal(0.5, 2),       Removal(0.1, 3))
    @test  isearlier(Removal(0.5, 3),       Removal(0.90, 2))
    @test  isearlier(CRemoval(0.10, 2),     Removal(0.5, 3))
    @test  isearlier(Removal(0.5, 3),       CRemoval(0.90, 2))
    @test  isearlier(CRemoval(0.10, 2),     CRemoval(0.5, 3))
    @test  isearlier(CRemoval(0.5, 3),      CRemoval(0.90, 2))
    @test  isearlier(Infection(0.10, 1, 2), Infection(0.5, 1, 3))
    @test !isearlier(Infection(0.70, 1, 2), Infection(0.5, 1, 3))
    @test  isearlier(Infection(0.10, 1, 2), Removal(0.5, 3))
    @test  isearlier(Removal(0.5, 3),       Infection(0.90, 1, 2))
    @test  isearlier(SIR(0.0, 1, 2, 1),     SIR(0.5, 0, 3, 1))
    @test !isearlier(SIR(0.0, 1, 2, 1),     SIR(0.0, 0, 3, 1))
    @test  isearlier(Removal(0.10, 2),      MarkerSusceptible(0.5, 3))
    @test !isearlier(Removal(0.5, 2),       MarkerInfected(0.1, 3))
end

## Testing to do with eliciting epidemic trajectory
# =================================
@testset "EpidemicsCFTP: chronology    " begin
    P, I, R, C = PInfection, Infection, Removal, CRemoval
    AI = AbstractIncident

    n = 3
    infects   = I[I(0.70, 1, 2)]
    allinfects  = Union{I, P}[P(0.70, 1, 2)]
    removals  = R[R(0.20, 3), R(0.10, 2)]
    cremovals = C[C(0.00, 1), C(0.05, 1)]
    
    # Correct result from `chronology`
    inn = Innovation(3, allinfects, removals, cremovals)
    chr = chronology(inn)
    for i in 1:length(chr)
        @test chr[i] == [C(0.00, 1), C(0.05, 1), R(0.10, 2), R(0.20, 3), P(0.70, 1, 2)][i]
    end
end

# =================================
@testset "EpidemicsCFTP: actions       " begin
    infect = EpidemicsCFTP.infect
    remove = EpidemicsCFTP.remove
    is_same_config = EpidemicsCFTP.is_same_config
    state = SIR(0.0, 0, 0, 1)
    @test_throws DomainError infect(0.0, state)
    @test_throws DomainError remove(0.0, state)
    state = SIR(0.0, 1, 1, 1)
    @test (st = infect(0.0, state) ; st.s == 0 && st.i == 2     )
    @test (st = remove(0.0, state) ; st.i == 0 && st.r == 2     )
    @test is_same_config(SIR(0.0, 0, 2, 1), infect(0.0, state)  )
    @test is_same_config(SIR(0.0, 1, 0, 2), remove(0.0, state)  )
    
    t, s, i, r = 0.0, 1, 2, 3
    state = SIR(t, s, i, r)
    for inc in [Infection, PInfection]
        is_infectable = EpidemicsCFTP.is_infectable
        @test   is_infectable(state, inc(0.0, r + 1, r + i + 1))
        @test ! is_infectable(state, inc(0.0, r + 1, r + i)    )
    end
    
	begin
        is_removeable = EpidemicsCFTP.is_removeable
	    inc = Removal
	    @test ! is_removeable(state, inc(0.0, 1)               )
	    @test ! is_removeable(state, inc(0.0, r)               )
	    @test   is_removeable(state, inc(0.0, r + 1)           )
	    @test   is_removeable(state, inc(0.0, r + i)           )
	    @test ! is_removeable(state, inc(0.0, r + i + 1)       )
	end

	begin
        is_removeable = EpidemicsCFTP.is_removeable
	    inc = CRemoval
	    @test ! is_removeable(state, inc(0.0, 1)            )
	    @test ! is_removeable(state, inc(0.0, r)            )
	    @test   is_removeable(state, inc(0.0, r + 1)        )
	    @test   is_removeable(state, inc(0.0, r + i)        )
	    @test ! is_removeable(state, inc(0.0, r + i + 1)    )
	end

# =================================
# 	for inc in [Infection, PInfection]
# 	    @test update(SIR(0.0, 1, 2, 3), inc(0.1, 4, 6)) == SIR(0.1,0,3,3)
# 	    @test update(SIR(0.0, 1, 2, 3), inc(0.1, 4, 5)) == SIR(0.1,1,2,3)
# 	end
# 
#     inc1 = Removal
#     @test update(SIR(0.0, 1, 2, 3), inc1(0.1, 4))    == SIR(0.1,1,1,4)
#     @test update(SIR(0.0, 1, 2, 3), inc1(0.1, 2))    == SIR(0.1,1,2,3)
# 
#     inc2 = CRemoval
#     @test update(SIR(0.0, 1, 2, 3), inc2(0.1, 3, 4))    == SIR(0.1,1,1,4)
#     @test update(SIR(0.0, 1, 2, 3), inc2(0.1, 1, 2))    == SIR(0.1,1,2,3)

end
