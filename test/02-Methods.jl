## Tests for `EpidemicsCFTP`
# =========================

### Testing `isless`
# ----------------------------------------------------------
@testset "EpidemicsCFTP: $(rpad(isless, 23))" begin
    import EpidemicsCFTP: Removal_order
    for typeR1 ∈ allconcretesubtypes(AbstractRemoval)
        for typeR2 ∈ allconcretesubtypes(AbstractRemoval)
            @test typeR1(0.2, 2) < typeR2(0.5, 3)
            @test typeR1(0.2, 2) > typeR2(0.1, 3)
            if Removal_order[typeR1] < Removal_order[typeR2]
                @test typeR1(0.5, 1) < typeR2(0.5, 1)
            end
        end
        for typeI2 ∈ allconcretesubtypes(AbstractInfection)
            @test typeR1(0.2, 2) < typeI2(0.5, 1, 3)
            @test typeR1(0.5, 2) > typeI2(0.2, 1, 3)
        end
    end
    import EpidemicsCFTP: Infection_order
    for typeI1 ∈ allconcretesubtypes(AbstractInfection)
        for typeI2 ∈ allconcretesubtypes(AbstractInfection)
            @test typeI1(0.2, 1, 2) < typeI2(0.5, 1, 3)
            @test typeI1(0.5, 1, 2) > typeI2(0.2, 1, 3)
            if Infection_order[typeI1] < Infection_order[typeI2]
                @test typeI1(0.5, 1, 2) < typeI2(0.5, 1, 2)
            end
        end
        for typeR2 ∈ allconcretesubtypes(AbstractRemoval)
            @test typeI1(0.2, 1, 2) < typeR2(0.5, 3)
            @test typeI1(0.5, 1, 2) > typeR2(0.2, 3)
        end
    end
    for typeR1 ∈ allconcretesubtypes(AbstractRemoval)
            @test typeR1(0.2, 2) < typeR1(0.2, 3)
            @test typeR1(0.2, 2) > typeR1(0.2, 1)
    end
    for typeI1 ∈ allconcretesubtypes(AbstractInfection)
            @test typeI1(0.2, 1, 2) < typeI1(0.2, 1, 3)
            @test typeI1(0.2, 1, 3) > typeI1(0.2, 1, 2)
            @test typeI1(0.2, 1, 3) < typeI1(0.2, 2, 3)
            @test typeI1(0.2, 2, 3) > typeI1(0.2, 1, 3)
    end
    for typeI1 ∈ allconcretesubtypes(AbstractInfection)
        for typeR2 ∈ allconcretesubtypes(AbstractRemoval)
            @test typeI1(0.2, 2, 3) < typeR2(0.2, 3)
            @test typeR2(0.2, 3)    > typeI1(0.2, 2, 3)
        end
    end
end

### Testing `alter`
# -------------------
@testset "EpidemicsCFTP: $(rpad(string(alter), 23))" begin
    crem = C(0.15, 1)
    @test alter(crem, 100) == C(0.15, 100)
    @test_throws ArgumentError   alter(crem, -100)
    # Now check non-integer second arguments cause errors!
    @test_throws MethodError     alter(crem,  100.5)
    @test_throws MethodError     alter(crem, -100.5)
end


### Testing various actions
# -------------------------
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
	
    for typeR ∈ allconcretesubtypes(OperativeRemoval)
        @test ! is_activatable(state, typeR(0.0, 1)               )
        @test ! is_activatable(state, typeR(0.0, r)               )
        @test   is_activatable(state, typeR(0.0, r + 1)           )
        @test   is_activatable(state, typeR(0.0, r + i)           )
        @test ! is_activatable(state, typeR(0.0, r + i + 1)       )
    end

    for typeR ∈ allconcretesubtypes(NonOperativeRemoval)
        @test ! is_activatable(state, typeR(0.0, 1)               )
        @test ! is_activatable(state, typeR(0.0, r)               )
        @test ! is_activatable(state, typeR(0.0, r + 1)           )
        @test ! is_activatable(state, typeR(0.0, r + i)           )
        @test ! is_activatable(state, typeR(0.0, r + i + 1)       )
    end

    for typeI ∈ allconcretesubtypes(OperativeInfection)
        @test update(SIR(0.0, 1, 2, 3), typeI(0.1, 4, 6)) == SIR(0.1,0,3,3)
        @test update(SIR(0.0, 1, 2, 3), typeI(0.1, 4, 5)) == SIR(0.1,1,2,3)
    end

    for typeI ∈ allconcretesubtypes(NonOperativeInfection)
	@test update(SIR(0.0, 1, 2, 3), typeI(0.1, 4, 6)) == SIR(0.1,1,2,3)
        @test update(SIR(0.0, 1, 2, 3), typeI(0.1, 4, 5)) == SIR(0.1,1,2,3)
    end

    for typeR ∈ allconcretesubtypes(NonOperativeRemoval)
        @test update(SIR(0.0, 1, 2, 3), typeR(0.1, 4))    == SIR(0.1,1,2,3)
        @test update(SIR(0.0, 1, 2, 3), typeR(0.1, 2))    == SIR(0.1,1,2,3)
    end
end


### Testing `evolution`
# --------------------
@testset "EpidemicsCFTP: $(rpad(string(evolution), 23))" begin
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
    innov5a        = Innovation(population, AIF[I(0.4, 4, 6), I(0.6, 3, 5)], 
                                R[R(0.5, 4)])
    outcome5a      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.4, 0, 3, 3), SIR(0.5, 0, 2, 4)], 
                      AI[I(0.4, 4, 6), R(0.5, 4)])
    
    innov5b        = Innovation(population, AIF[I(0.4, 4, 6), I(0.6, 3, 5)], 
                                R[R(0.5, 4), R(0.7, 6)])
    outcome5b      = (SIR[SIR(0.0, 1, 2, 3), SIR(0.4, 0, 3, 3), SIR(0.5, 0, 2, 4), 
                          SIR(0.7, 0, 1, 5)], 
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

### Testing maximal and minimal constructions
# -------------------------------------------
@testset "EpidemicsCFTP: $(rpad("extremal", 23))" begin
    initial = SIR(0.0, 2, 1, 0)
    pop     = initial.n
    ev_max  = extremal_evolution(initial, 4.0, [1.0, 2.0, 3.0])
    ev_min  = extremal_evolution(initial, 4.0, [1.0, 2.0, 3.0], maximal=false)

    @test ev_max.infections == AIF[I(0.0, 1, 2), I(0.0, 2, 3)]
    @test isempty(ev_max.removals)
    @test ev_max.cremovals  == C[C(1.0, initial.n), C(2.0, initial.n), C(3.0, initial.n)]
    @test ev_min.infections == AIF[I(1.0, 1, 2), I(2.0, 2, 3)]
    @test isempty(ev_min.removals)
    @test ev_min.cremovals  == C[C(1.0, 1), C(2.0, 2), C(3.0, 3)]

    ev_max1  = extremal_evolution(initial, 4.0, [1.0, 2.0], all_cremovals_observed=true)
    @test ev_max1.infections == AIF[I(0.0, 1, 2)]
    @test isempty(ev_max1.removals)
    @test ev_max1.cremovals  == C[C(1.0, 2), C(2.0, 2)]
end 

### Testing `create_start` and `create_finis` _via_ `CEvolution`
# -------------------------------------------------------------
@testset "EpidemicsCFTP: $(rpad("interval computation", 23))" begin
    initial        = SIR(0.0, 2, 1, 0)
    n              = initial.n
    innov1         = Innovation(n, I[I(1,1,2), I(2,2,3)], R[], C[C(3,2)])
    evol1          = CEvolution(initial, innov1)
    @test evol1.history == AI[I(1,1,2),       I(2,2,3),   C(3,2)]
    @test evol1.start   == AIF[IM(-Inf,0,1),  I(1,1,2),   I(2,2,3)]
    @test evol1.finis   == AIR[C(3,2),       RM(Inf,2),  RM(Inf,3)]
    
    # Testing a fast `CEvolution`
    innov2         = Innovation(n, I[I(0,1,2), I(0,2,3)], R[], C[C(3,2)])
    evol2          = CEvolution(initial, innov2)
    @test evol2.history == AI[I(0,1,2),       I(0,2,3),   C(3,2)  ]
    @test evol2.start   == AIF[IM(-Inf,0,1),  I(0,1,2),   I(0,2,3)]
    @test evol2.finis   == AIR[C(3,2),       RM(Inf,2),  RM(Inf,3)]
    
    # Testing a slow `CEvolution`
    innov3         = Innovation(n, I[I(2,1,2), I(3,2,3)], R[], C[C(2,2), C(3,3)])
    evol3          = CEvolution(initial, innov3)
    @test evol3.history == AI[I(2,1,2),      C(2,2),    I(3,2,3), C(3,3)]
    @test evol3.start   == AIF[IM(-Inf,0,1), I(2,1,2),  I(3.0,2,3)      ]
    @test evol3.finis   == AIR[C(2,2),       C(3,3),   RM(Inf,3)        ]
    
    # Notice here that `3` time line never starts!
    innov4         = Innovation(n, I[I(2,1,2)], R[], C[C(2,2), C(3,2)])
    evol4          = CEvolution(initial, innov4)
    @test evol4.history == AI[I(2.0,1,2),    C(2.0,2),  C(3.0,2)  ]
    @test evol4.start   == AIF[IM(-Inf,0,1), I(2,1,2), IM(Inf,2,3)] 
    @test evol4.finis   == AIR[C(2,2),       C(3,2),   RM(Inf,3)  ]
end 


### Testing `update` exception raising
# ------------------------------------
# `FakeIncident` is an `AbstractIncident but without fields`
struct FakeIncident <: AbstractIncident end

    
# Function `update` does not accept this!
@testset "EpidemicsCFTP: $(rpad("SIR fake", 23))" begin
    @test_throws UndefVarError update(SIR(0.0, 1, 2, 3), FakeIncident())
end


### Testing updating of a `CEvolution` by an `Innovaton`
# -----------------------------------------------------
@testset "EpidemicsCFTP: $(rpad("Testing one-step", 23))" begin
begin
    initial = SIR(0,4,1,0,5)
    ev1 = CEvolution(initial, AI[I(2,1,2), C(2,1), C(4,2)],)
    iv1 = CInnovation(5,
  AIF[I(0.5,2,4),I(0.65,2,3),I(0.7,2,3),I(1,3,4),I(1.3,1,4),I(1.4,1,4),I(1.5,2,3),I(1.55,1,3),I(2.3,2,5),I(2.8,2,5),I(2.9,1,3),I(3.1,1,5),I(3.5,1,5),I(3.7,1,2),I(4.4,3,5),I(4.5,2,5),I(4.7,1,2),I(4.9,2,3),I(4.93,1,5),I(4.95,1,3)],
  AIR[R(1.1,4), R(1.8,4), R(4.1,1)],
  C[C(2,4),C(4,5)])
    chron2 = AI[I(0.5,2,4),I(0.65,2,3),NF(0.7,2,3),I(1,3,4),R(1.1,4),I(1.3,1,4),NF(1.4,1,4),I(1.5,2,3),I(1.55,1,3),R(1.8,4),P(2,1,2),C(2,1),I(2.3,2,5),I(2.8,2,5),KI(2.9,1,3),KI(3.1,1,5),KI(3.5,1,5),KI(3.7,1,2),C(4,2),KR(4.1,1),I(4.4,3,5),KI(4.5,2,5),KI(4.7,1,2),KI(4.9,2,3),KI(4.93,1,5),KI(4.95,1,3)]
    ev2 = CEvolution(initial, chron2)
    ev_new = ev1 ⋄ iv1
    @test(setdiff(chron2, ev_new.chronology) == AI[])
    @test(setdiff(ev_new.chronology, chron2) == AI[])
    @test chron2 == ev_new.chronology
end


# Produced from `CFTP.qmd` at index=4, maximal
begin
    initial = SIR(0,4,1,0,5)

    dev1 = CEvolution(initial,
        AI[I(1,3,5),I(2,1,3),I(7,1,2),I(8,1,2),I(9,2,3),I(11,2,3),I(13,2,5),I(14,1,4),C(15,1),I(16,2,4),KI(17,1,2),I(18,2,5),KI(19,1,4),I(24,3,4),KI(25,1,3),I(26,2,4),I(27,4,5),C(31,5),KI(32,1,2),KI(33,2,5),KI(35,2,3),KI(38,2,3),KI(41,1,2),KI(44,1,5)]
        )

    div2 = CInnovation(5,
        AIF[I(3,2,4),I(4,1,3),I(6,1,2),I(10,3,5),I(12,1,4),I(20,1,5),I(21,1,2),I(22,2,5),I(23,1,2),I(28,2,4),I(30,1,3),I(36,1,3),I(37,2,3),I(39,1,3),I(40,1,4),I(42,1,2),I(43,2,3),I(45,1,2),I(46,3,4),I(47,1,4)],
        AIR[R(5,2),R(29,5),R(34,1)],
        C[C(15,2),C(31,1)]
        )

    dev2 = CEvolution(initial,
        AI[I(3,2,4),I(4,1,3),R(5,2),I(6,1,2),P(7,1,2),P(9,2,3),I(10,3,5),I(12,1,4),P(14,1,4),C(15,2),KI(20,1,5),KI(21,1,2),I(22,2,5),KI(23,1,2),I(28,2,4),KI(30,1,3),C(31,5),KR(34,1),KI(36,1,3),KI(37,2,3),KI(39,1,3),KI(40,1,4),KI(42,1,2),KI(43,2,3),KI(45,1,2),I(46,3,4),KI(47,1,4)];
        LFE=AI[P(7,1,2),P(9,2,3),P(14,1,4),C(15,2),I(22,2,5),C(31,5)],
        NFZ=Real[-Inf,5,5,5,5]
        )

    ddev2 = dev1 ⋄ div2

    @test dev2.infections == ddev2.infections
    @test dev2.removals   == ddev2.removals
    @test dev2.cremovals  == ddev2.cremovals
    @test dev2.LFE        == ddev2.LFE
    @test dev2.NFZ        == ddev2.NFZ
end


# Produced from `CFTP.qmd` at index=12, minimal
begin
    initial = SIR(0,4,1,0,5)

    dev1 = CEvolution(initial,
        AI[XI(1,1,2),I(2,2,3),R(3,2),I(5,2,3),R(8,2),I(9,3,4),I(10,3,4),I(11,1,3),I(12,2,3),I(15,1,2),I(16,2,4),I(17,3,4),I(18,1,3),I(19,1,3),I(22,1,2),I(23,1,2),C(24,3),I(32,4,5),KI(33,1,2),KI(35,1,4),KI(39,1,2),I(40,2,4),I(42,2,4),KI(43,1,4),KI(45,1,3),I(46,2,3),KI(48,1,4),KI(49,1,4),C(50,4),KI(51,1,3),KI(52,2,3),KI(53,2,3),KI(55,2,3),KI(56,1,3),KI(58,1,3),KR(59,2),I(60,4,5)]
        )

    div2 = CInnovation(5,
        AIF[I(4,3,4),I(6,2,3),I(7,2,3),I(14,3,4),I(20,1,3),I(21,1,3),I(25,1,2),I(26,1,2),I(28,1,3),I(29,1,3),I(30,1,3),I(31,2,3),I(34,1,4),I(37,1,3),I(41,4,5),I(44,4,5),I(47,1,4),I(54,1,3),I(57,2,4)],
        AIR[R(13,3),R(27,2),R(36,4),R(38,1)],
        C[C(24,3),C(50,4)]
        )

    dev2 = CEvolution(initial,
        AI[I(4,3,4),I(6,2,3),NF(7,2,3),R(13,3),NF(14,3,4),P(15,1,2),I(20,1,3),I(21,1,3),C(24,3),KI(25,1,2),KI(26,1,2),KI(28,1,3),KI(29,1,3),KI(30,1,3),I(31,2,3),KI(34,1,4),R(36,4),KI(37,1,3),KR(38,1),P(40,2,4),I(41,4,5),I(44,4,5),KI(47,1,4),C(50,4),KI(54,1,3),KI(57,2,4)];
        LFE=AI[P(15,1,2),I(21,1,3),C(24,3),P(40,2,4),C(50,4)],
        NFZ=Real[-Inf,7,14,36,36]
        )

    ddev2 = dev1 ⋄ div2

    @test dev2.infections == ddev2.infections
    @test dev2.removals   == ddev2.removals
    @test dev2.cremovals  == ddev2.cremovals
    @test dev2.LFE        == ddev2.LFE
    @test dev2.NFZ        == ddev2.NFZ
end

# Produced from `CFTP.qmd` at index=5, minimal
begin
    initial = SIR(0,4,1,0,5)

    dev1 = CEvolution(initial,
        AI[I(1,2,4),I(2,1,3),R(4,2),I(8,1,2),P(10,1,2),I(13,3,5),I(14,1,4),C(19,2),KI(21,1,5),KI(23,1,2),I(25,2,5),KI(26,1,2),I(34,2,4),KI(35,1,3),C(38,2),KR(41,1),KI(42,1,3),KI(43,2,3),KI(44,1,3),KI(45,1,4),KI(47,1,2),KI(48,2,3),KI(49,1,2),I(50,3,4),KI(55,1,4)]
        )

    div2 = CInnovation(5,
        AIF[I(3,1,2),I(5,3,4),I(6,1,2),I(11,3,4),I(12,1,2),I(15,1,3),I(16,1,2),I(17,1,2),I(18,3,5),I(20,1,3),I(24,1,3),I(27,1,3),I(28,1,2),I(29,1,4),I(30,1,3),I(31,1,3),I(32,1,2),I(36,1,2),I(37,1,2),I(39,1,2),I(40,1,3),I(46,1,2),I(52,1,5),I(53,1,3)],
        AIR[R(7,3),R(9,3),R(22,2),R(33,5),R(51,4),R(54,4)],
        C[C(19,2),C(38,4)]
        )

    dev2 = CEvolution(initial,
        AI[I(3,1,2),I(5,3,4),I(6,1,2),R(7,3),R(9,3),NF(11,3,4),I(12,1,2),I(15,1,3),I(16,1,2),I(17,1,2),I(18,3,5),C(19,2),KI(20,1,3),KI(24,1,3),KI(27,1,3),KI(28,1,2),KI(29,1,4),KI(30,1,3),KI(31,1,3),KI(32,1,2),R(33,5),KI(36,1,2),KI(37,1,2),C(38,2),KI(39,1,2),KI(40,1,3),KI(46,1,2),R(51,4),KI(52,1,5),KI(53,1,3),R(54,4)];
        LFE=AI[I(17,1,2),C(19,2),C(38,2)],
        NFZ=Real[-Inf,-Inf,11,54,54]
        )

    ddev2 = dev1 ⋄ div2

    @test dev2.infections == ddev2.infections
    @test dev2.removals   == ddev2.removals
    @test dev2.cremovals  == ddev2.cremovals
    @test dev2.LFE        == ddev2.LFE
    @test dev2.NFZ        == ddev2.NFZ
end

# Produced from `CFTP.qmd` at index=8,maximal
begin
    initial = SIR(0,4,1,0,5)

    dev1 = CEvolution(initial,
        AI[I(1,2,4),P(3,1,2),I(6,3,5),C(9,2),KI(10,1,2),I(11,2,5),KI(12,1,5),R(14,3),KI(17,1,3),I(19,3,4),KI(20,1,5),KI(21,1,2),KI(22,1,2),I(23,2,5),KI(25,1,4),KI(26,1,2),KI(27,1,3),C(28,2),I(35,3,4),KI(36,1,2),KI(38,2,3)]
        )

    div2 = CInnovation(5,
        AIF[I(2,1,2),I(4,1,3),I(5,1,4),I(8,1,3),I(13,1,3),I(15,1,2),I(18,1,3),I(24,2,5),I(29,3,5),I(30,3,4),I(31,1,3),I(32,1,2),I(33,1,4),I(34,1,2),I(37,1,2)],
        AIR[R(7,3),R(16,4)],
        C[C(9,5),C(28,5)]
        )

    dev2 = CEvolution(initial,
        AI[I(2,1,2),P(3,1,2),XI(4,1,3),I(5,1,4),R(7,3),I(8,1,3),C(9,2),KI(13,1,3),KI(15,1,2),R(16,4),KI(18,1,3),I(24,2,5),C(28,2),I(29,3,5),I(30,3,4),KI(31,1,3),KI(32,1,2),KI(33,1,4),KI(34,1,2),KI(37,1,2)];
        LFE=AI[P(3,1,2),C(9,2),C(28,2)],
        NFZ=Real[-Inf,-Inf,7,16,16]
        )

    ddev2 = dev1 ⋄ div2

    @test dev2.infections == ddev2.infections
    @test dev2.removals   == ddev2.removals
    @test dev2.cremovals  == ddev2.cremovals
    @test dev2.LFE        == ddev2.LFE
    @test dev2.NFZ        == ddev2.NFZ
end
end
