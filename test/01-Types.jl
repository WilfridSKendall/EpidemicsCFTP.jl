# Tests for types of `EpidemicsCFTP`

## Testing creation of concrete subtypes of `AbstractRemoval`
@testset "EpidemicsCFTP: $(rpad(AbstractRemoval, 18))  (A)" begin
    for typeR ∈ allconcretesubtypes(AbstractRemoval)
        @test_throws DomainError    typeR(0.05,-2)
        @test_throws DomainError    typeR(0.05, 0)
        @test_throws MethodError    typeR(0.05, 2.5)
        @test_throws MethodError    typeR(0.05,-2.3)
    end
end

## Testing conversion of concrete subtypes of `AbstractRemoval`
@testset "EpidemicsCFTP: $(rpad(AbstractRemoval, 18))  (B)" begin
    for typeR1 ∈ allconcretesubtypes(AbstractRemoval)
        for typeR2 ∈ allconcretesubtypes(AbstractRemoval)
            @test typeR1(typeR2(0.05, 2)) == typeR1(0.05, 2)
            @test typeR1(typeR2(0.15, 3)) == typeR1(0.15, 3)
        end
    end
end

## Testing creation of concrete subtypes of `AbstractInfection`
@testset "EpidemicsCFTP: $(rpad(AbstractInfection, 18))  (A)" begin
    for typeI ∈ allconcretesubtypes(AbstractInfection)
        @test_throws DomainError  typeI(0.10,-1,   2)
        @test_throws DomainError  typeI(0.10, 1,  -2)
        @test_throws DomainError  typeI(0.10,-1,  -2)
        @test_throws DomainError  typeI(0.10, 1,   0)
        if typeI == InfectionMarker
            @test_throws DomainError  typeI(5.45,-1,   3)
            @test_throws DomainError  typeI(5.45,-1,   0)
        else
            @test_throws DomainError  typeI(5.45, 0,   3)
            @test_throws DomainError  typeI(5.45, 0,   0)
        end
        @test_throws MethodError  typeI(0.10, 1.5, 2)
        @test_throws MethodError  typeI(0.10, 1,   2.5)
        @test_throws MethodError  typeI(0.10, 1.5, 2.5)
        @test_throws MethodError  typeI(0.10, 2.5, 1)
        @test_throws DomainError  typeI(5.45, 3,   2)
    end
end

## Testing creation of concrete subtypes of `AbstractInfection`
@testset "EpidemicsCFTP: $(rpad(AbstractInfection, 18))  (B)" begin
    for typeI1 ∈ allconcretesubtypes(AbstractInfection)
        for typeI2 ∈ allconcretesubtypes(AbstractInfection)
            @test typeI1(typeI2(0.05, 2, 3)) == typeI1(0.05, 2, 3)
            @test typeI1(typeI2(0.15, 1, 4)) == typeI1(0.15, 1, 4)
        end
    end
end

## Testing creation of `SIR`, state of epidemic
@testset "EpidemicsCFTP: $(rpad(string(SIR), 23))" begin
    @test_throws DomainError SIR(0.0,-1, 2, 3)
    @test_throws DomainError SIR(0.0, 1, 2,-3)
    @test_throws DomainError SIR(0.0, 0, 0, 0)
    @test_throws DomainError SIR(0.0, 1,-2, 3, 2)
    @test_throws DomainError SIR(0.0, 1, 2,-3, 0)
    @test_throws DomainError SIR(0.0, 0, 0, 0, 0)
    @test_throws DomainError SIR(0.0, 1, 1, 1, 2)
    @test_throws DomainError SIR(0.0, 1, 1, 1, 1)
    sir = SIR(0.0, 1, 2, 3)
    @test sir.n == sir.s + sir.i + sir.r
    sir = SIR(0,   1, 2, 3)
    @test sir.n == sir.s + sir.i + sir.r
    sir = SIR(Inf, 1, 2, 3)
    @test sir.n == sir.s + sir.i + sir.r
end

## Testing creation of concrete subtypes of `AbstractEvolution`
@testset "EpidemicsCFTP: $(rpad(AbstractEvolution, 23))" begin
    initial    = SIR(0, 2, 1, 0)
    infections = [NoFlyInfection(0,2,3), ExpungedInfection(2, 2, 3), 
                  Infection(7,1,2), PInfection(5,1,2)]
    removals   = [Removal(1, 1), KilledRemoval(2, 3), Removal(0.11, 2)]
    cremovals  = [CRemoval(0, 1)]
    for evolutiontype ∈ allconcretesubtypes(AbstractEvolution)
        ev = evolutiontype(initial, infections ∪ removals ∪ cremovals)
        @test ev.initial == ev.trajectory[1]
    end
end

## Testing construction of `Innovation`
@testset "EpidemicsCFTP: $(rpad(string(Innovation), 23))" begin
    P, I, R, C = PInfection, Infection, Removal, CRemoval
    AI = AbstractIncident

    population = 3
    infects    = I[I(0.60, 1, 2)]
    allinfects = Union{I, P}[P(0.70, 1, 2)]
    removals   = R[R(0.20, 3), R(0.10, 2)]
    cremovals  = C[C(0.00, 1), C(0.05, 1)]
    
    # Population size not positive
    @test_throws DomainError Innovation(0, allinfects, removals, cremovals)

    # Signature violations
    @test_throws MethodError Innovation(population, allinfects, cremovals, removals)
    @test_throws MethodError Innovation(population, removals, allinfects, cremovals)
 
    # Too many conditional removals
    @test_throws ArgumentError Innovation(population, allinfects, removals, 
            C[C(0.00, 1), C(0.01, 1), C(0.02, 1), C(0.05, 1)])

    inn = Innovation(population, allinfects, removals, cremovals)
    @test inn.removals == R[R(0.10, 2), R(0.20, 3)]

    # Correct result from `chronology
    @test inn.chronology == [C(0.00, 1), C(0.05, 1), R(0.10, 2), R(0.20, 3), 
                             P(0.70, 1, 2)]

    # Now with integer times!
    population = 3
    infects    = I[I(6, 1, 2)]
    allinfects = Union{I, P}[P(7, 1, 2)]
    removals   = R[R(3, 3), R(2, 2)]
    cremovals  = C[C(0, 1), C(1, 1)]
    
    inn = Innovation(population, allinfects, removals, cremovals)
    @test inn.removals == R[R(2.0, 2), R(3.0, 3)]

    # Correct result from `chronology
    @test inn.chronology == [C(0.0, 1), C(1.0, 1), R(2.0, 2), R(3.0, 3), P(7.0, 1, 2)]

end

## Testing construction of `CEvolution`
@testset "EpidemicsCFTP: $(rpad(CEvolution, 23))" begin
    I, P, R, C         = PInfection, Infection, Removal, CRemoval
    IM, RM             = InfectionMarker, RemovalMarker
    NFI, EI, KR        = NoFlyInfection, ExpungedInfection, KilledRemoval
    AIF, AIR           = AbstractInfection, AbstractRemoval
    initial    = SIR(0.0, 2, 1, 0)
    infections = [NFI(0.5,2,3), EI(1.5,2,3), I(1,1,2), P(3,2,3)]
    removals   = [R(0.5,2), R(0.25,3), KR(0.5,1)]
    cremovals  = [C(2,1), C(4,2)]
    uev        = Evolution(initial, infections ∪ removals ∪ cremovals)
    early_inactivated_removals = [z for z ∈ removals if z < uev.start[z.target]]
    NFZ1       = repeat([0.0], initial.n)
    for z ∈ early_inactivated_removals
        NFZ1[z.target]  = max(NFZ1[z.target], z.t)
    end
    NFZ2       = accumulate(max, NFZ1)
    ev         = CEvolution(initial, infections ∪ removals ∪ cremovals,
                                NFZ1=NFZ1, NFZ2=NFZ2)
    @test ev.start == AIF[IM(-Inf,0,1), I(1,1,2), P(3,2,3)]
    @test ev.NFZ1  == Real[0, 0.5, 0.25]
    @test ev.NFZ2  == Real[0, 0.5, 0.5]
    @test ev.finis == AIR[C(2,1), C(4,2), RM(Inf,3)]
end

