# Tests for `EpidemicsCFTP`

## Testing `isearlier`
# =================================
@testset "EpidemicsCFTP: $(rpad(isearlier, 23))" begin
    for removaltype1 ∈ allconcretesubtypes(AbstractRemoval)
        for removaltype2 ∈ allconcretesubtypes(AbstractRemoval)
            @test   isearlier(removaltype1(0.1, 2),      removaltype2(0.5, 3))
            @test ! isearlier(removaltype1(0.5, 2),      removaltype2(0.1, 3))
        end
        for infectiontype2 ∈ allconcretesubtypes(AbstractInfection)
            @test   isearlier(removaltype1(0.1, 2),      infectiontype2(0.5, 1, 3))
            @test ! isearlier(removaltype1(0.5, 2),      infectiontype2(0.1, 1, 3))
        end
    end
    for infectiontype1 ∈ allconcretesubtypes(AbstractInfection)
        for infectiontype2 ∈ allconcretesubtypes(AbstractInfection)
            @test   isearlier(infectiontype1(0.1, 1, 2), infectiontype2(0.5, 1, 3))
            @test ! isearlier(infectiontype1(0.5, 1, 2), infectiontype2(0.1, 1, 3))
        end
        for removaltype2 ∈ allconcretesubtypes(AbstractRemoval)
            @test   isearlier(infectiontype1(0.1, 1, 2), removaltype2(0.5, 3))
            @test ! isearlier(infectiontype1(0.5, 1, 2), removaltype2(0.1, 3))
        end
    end
end

## Testing `alter`
# -------------------
@testset "EpidemicsCFTP: $(rpad(string(alter), 23))" begin
crem = CRemoval(0.15, 1)
@test alter(crem, 100) == CRemoval(0.15, 100)
@test_throws ArgumentError   alter(crem, -100)
@test_throws MethodError     alter(crem,  100.5) # No signature for non-integer second argument!
@test_throws MethodError     alter(crem, -100.5) # No signature for non-integer second argument!
end



# =================================
@testset "EpidemicsCFTP: $(rpad("actions", 23))" begin
    infect = EpidemicsCFTP.infect
    remove = EpidemicsCFTP.remove
    update = EpidemicsCFTP.update
    is_activatable = EpidemicsCFTP.is_activatable
    is_same_config = EpidemicsCFTP.is_same_config
    
    state = SIR(0.0, 0, 0, 1)
    @test_throws DomainError infect(0.0, state)
    @test_throws DomainError remove(0.0, state)
    
    state = SIR(0.0, 1, 1, 1)
    @test (st = infect(0.0, state) ; st.s == 0 && st.i == 2     )
    @test (st = remove(0.0, state) ; st.i == 0 && st.r == 2     )
    # NB configurations agree but times do not!
    @test is_same_config(SIR(0.0, 0, 2, 1), infect(4.0, state)  )
    @test is_same_config(SIR(0.0, 1, 0, 2), remove(4.0, state)  )
    
    t, s, i, r = 0.0, 1, 2, 3
    state = SIR(t, s, i, r)
    for infecttype ∈ allconcretesubtypes(OperativeInfection)
        @test   is_activatable(state, infecttype(0.0, r + 1, r + i + 1))
        @test ! is_activatable(state, infecttype(0.0, r + 1, r + i)    )
    end
    
    for infecttype ∈ allconcretesubtypes(NonOperativeInfection)
        @test ! is_activatable(state, infecttype(0.0, r + 1, r + i + 1))
        @test ! is_activatable(state, infecttype(0.0, r + 1, r + i)    )
    end
	
    for removaltype ∈ allconcretesubtypes(OperativeRemoval)
        @test ! is_activatable(state, removaltype(0.0, 1)               )
        @test ! is_activatable(state, removaltype(0.0, r)               )
        @test   is_activatable(state, removaltype(0.0, r + 1)           )
        @test   is_activatable(state, removaltype(0.0, r + i)           )
        @test ! is_activatable(state, removaltype(0.0, r + i + 1)       )
    end

    for removaltype ∈ allconcretesubtypes(NonOperativeRemoval)
        @test ! is_activatable(state, removaltype(0.0, 1)               )
        @test ! is_activatable(state, removaltype(0.0, r)               )
        @test ! is_activatable(state, removaltype(0.0, r + 1)           )
        @test ! is_activatable(state, removaltype(0.0, r + i)           )
        @test ! is_activatable(state, removaltype(0.0, r + i + 1)       )
    end

    for infectiontype ∈ allconcretesubtypes(OperativeInfection)
        @test update(SIR(0.0, 1, 2, 3), infectiontype(0.1, 4, 6)) == SIR(0.1,0,3,3)
        @test update(SIR(0.0, 1, 2, 3), infectiontype(0.1, 4, 5)) == SIR(0.1,1,2,3)
    end

    for infectiontype ∈ allconcretesubtypes(NonOperativeInfection)
	@test update(SIR(0.0, 1, 2, 3), infectiontype(0.1, 4, 6)) == SIR(0.1,1,2,3)
        @test update(SIR(0.0, 1, 2, 3), infectiontype(0.1, 4, 5)) == SIR(0.1,1,2,3)
    end

    for removaltype ∈ allconcretesubtypes(NonOperativeRemoval)
        @test update(SIR(0.0, 1, 2, 3), removaltype(0.1, 4))    == SIR(0.1,1,2,3)
        @test update(SIR(0.0, 1, 2, 3), removaltype(0.1, 2))    == SIR(0.1,1,2,3)
    end
end


@testset "EpidemicsCFTP: $(rpad(string(evolution), 23))" begin
    I, P, R, C = PInfection, Infection, Removal, CRemoval
    AIF = AbstractInfection
    AI  = AbstractIncident
    population     = 6
    initial_state1 = SIR(0.0, 1, 2, 3)
    innov1a        = Innovation(population, I[], R[R(0.5, 4)])
    outcome1a      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.5, 1, 1, 4)], 
                      AI[R(0.5, 4)])
    innov1b        = Innovation(population, I[], R[], C[C(0.5, 4)])
    outcome1b      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.5, 1, 1, 4)], 
                      AI[C(0.5, 4)])
    
    initial_state2 = SIR(0.6, 1, 2, 3)
    outcome2       = (SIR[SIR(0.6, 1, 2, 3)], AI[])
    
    initial_state3 = SIR(-0.6, 1, 2, 3)
    outcome3a      = (SIR[SIR(-0.6, 1, 2, 3), SIR(0.5, 1, 1, 4)], 
                      AI[R(0.5, 4)])
    outcome3b      = (SIR[SIR(-0.6, 1, 2, 3), SIR(0.5, 1, 1, 4)], 
                      AI[C(0.5, 4)])
    
    initial_state4 = initial_state1
    innov4a        = Innovation(population, AIF[I(0.4, 4, 6)], R[])
    outcome4a      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.4, 0, 3, 3)], 
                      AI[I(0.4, 4, 6)])
    innov4b        = Innovation(population, AIF[P(0.4, 4, 6)], R[], C[])
    outcome4b      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.4, 0, 3, 3)], 
                      AI[P(0.4, 4, 6)])
    innov4c        = Innovation(population, AIF[P(0.4, 4, 6)], R[R(0.5, 4)])
    outcome4c      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.4, 0, 3, 3), SIR(0.5, 0, 2, 4)], 
                      AI[P(0.4, 4, 6), R(0.5, 4)])
    
    initial_state5 = initial_state1
    innov5a        = Innovation(population, AIF[I(0.4, 4, 6), I(0.6, 3, 5)], R[R(0.5, 4)])
    outcome5a      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.4, 0, 3, 3), SIR(0.5, 0, 2, 4)], 
                      AI[I(0.4, 4, 6), R(0.5, 4)])
    
    innov5b        = Innovation(population, AIF[I(0.4, 4, 6), I(0.6, 3, 5)], R[R(0.5, 4), R(0.7, 6)])
    outcome5b      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.4, 0, 3, 3), SIR(0.5, 0, 2, 4), SIR(0.7, 0, 1, 5)], 
                      AI[I(0.4, 4, 6), R(0.5, 4), R(0.7, 6)])
    
    @test evolution(initial_state1, innov1a) == outcome1a
    @test evolution(initial_state1, innov1b) == outcome1b
    
    @test evolution(initial_state2, innov1a) == outcome2
    @test evolution(initial_state2, innov1b) == outcome2
    
    @test evolution(initial_state3, innov1a) == outcome3a
    @test evolution(initial_state3, innov1b) == outcome3b
    
    @test evolution(initial_state4, innov4a) == outcome4a
    @test evolution(initial_state4, innov4b) == outcome4b
    @test evolution(initial_state4, innov4c) == outcome4c

    @test evolution(initial_state5, innov5a) == outcome5a
    @test evolution(initial_state5, innov5b) == outcome5b

    
    @test evolution_history(initial_state1, innov1a) == outcome1a[2]
    @test evolution_history(initial_state1, innov1b) == outcome1b[2]
    
    @test evolution_history(initial_state2, innov1a) == outcome2[2]
    @test evolution_history(initial_state2, innov1b) == outcome2[2]
    
    @test evolution_history(initial_state3, innov1a) == outcome3a[2]
    @test evolution_history(initial_state3, innov1b) == outcome3b[2]
    
    @test evolution_history(initial_state4, innov4a) == outcome4a[2]
    @test evolution_history(initial_state4, innov4b) == outcome4b[2]
    @test evolution_history(initial_state4, innov4c) == outcome4c[2]

    @test evolution_history(initial_state5, innov5a) == outcome5a[2]
    @test evolution_history(initial_state5, innov5b) == outcome5b[2]

end


## `FakeIncident` is an `AbstractIncident but without fields`
struct FakeIncident <: AbstractIncident end

    
# Function `update` does not accept this!
@testset "EpidemicsCFTP: $(rpad("SIR fake", 23))" begin
    @test_throws UndefVarError update(SIR(0.0, 1, 2, 3), FakeIncident())
end

