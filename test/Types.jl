# Tests for types of `EpidemicsCFTP`

## Testing creation of concrete subtypes of `AbstractRemoval`
@testset "EpidemicsCFTP: $(rpad(AbstractRemoval, 18))  (A)" begin
    for removaltype in allconcretesubtypes(AbstractRemoval)
        @test_throws DomainError    removaltype(0.05,-2)
        @test_throws DomainError    removaltype(0.05, 0)
        @test_throws MethodError    removaltype(0.05, 2.5)
        @test_throws MethodError    removaltype(0.05,-2.3)
    end
end

## Testing conversion of concrete subtypes of `AbstractRemoval`
@testset "EpidemicsCFTP: $(rpad(AbstractRemoval, 18))  (B)" begin
    for removaltype1 in allconcretesubtypes(AbstractRemoval)
        for removaltype2 in allconcretesubtypes(AbstractRemoval)
            @test removaltype1(removaltype2(0.05, 2)) == removaltype1(0.05, 2)
            @test removaltype1(removaltype2(0.15, 3)) == removaltype1(0.15, 3)
        end
    end
end

## Testing creation of concrete subtypes of `AbstractInfection`
@testset "EpidemicsCFTP: $(rpad(AbstractInfection, 18))  (A)" begin
    for infectiontype in allconcretesubtypes(AbstractInfection)
        @test_throws DomainError  infectiontype(0.10,-1,   2)
        @test_throws DomainError  infectiontype(0.10, 1,  -2)
        @test_throws DomainError  infectiontype(0.10,-1,  -2)
        @test_throws DomainError  infectiontype(0.10, 1,   0)
        @test_throws DomainError  infectiontype(5.45, 0,   3)
        @test_throws DomainError  infectiontype(5.45, 0,   0)
        @test_throws MethodError  infectiontype(0.10, 1.5, 2)
        @test_throws MethodError  infectiontype(0.10, 1,   2.5)
        @test_throws MethodError  infectiontype(0.10, 1.5, 2.5)
        @test_throws MethodError  infectiontype(0.10, 2.5, 1)
        @test_throws DomainError  infectiontype(5.45, 3,   2)
    end
end

## Testing creation of concrete subtypes of `AbstractInfection`
@testset "EpidemicsCFTP: $(rpad(AbstractInfection, 18))  (B)" begin
    for infectiontype1 in allconcretesubtypes(AbstractInfection)
        for infectiontype2 in allconcretesubtypes(AbstractInfection)
            @test infectiontype1(infectiontype2(0.05, 2, 3)) == infectiontype1(0.05, 2, 3)
            @test infectiontype1(infectiontype2(0.15, 1, 4)) == infectiontype1(0.15, 1, 4)
        end
    end
end

@testset "EpidemicsCFTP: $(rpad(string(Innovation), 23))" begin
    P, I, R, C = PInfection, Infection, Removal, CRemoval
    AI = AbstractIncident

    population = 3
    infects    = I[I(0.70, 1, 2)]
    allinfects = Union{I, P}[P(0.70, 1, 2)]
    removals   = R[R(0.20, 3), R(0.10, 2)]
    cremovals  = C[C(0.00, 1), C(0.05, 1)]
    
    inn = Innovation(population, allinfects, removals, cremovals)
    @test inn.removals == R[R(0.10, 2), R(0.20, 3)]
    
    # Population size not positive
    @test_throws DomainError Innovation(0, allinfects, removals, cremovals)

    # Signature violations
    @test_throws MethodError Innovation(population, allinfects, cremovals, removals)
    @test_throws MethodError Innovation(population, removals, allinfects, cremovals)
 
    # Too many conditional removals
    @test_throws ArgumentError Innovation(population, allinfects, removals, 
            C[C(0.00, 1), C(0.01, 1), C(0.02, 1), C(0.05, 1)])

    # Testing `chronology` field of `Innovation`
    infects   = I[I(0.70, 1, 2)]
    allinfects  = Union{I, P}[P(0.70, 1, 2)]
    removals  = R[R(0.20, 3), R(0.10, 2)]
    cremovals = C[C(0.00, 1), C(0.05, 1)]
    
    # Correct result from `chronology`
    inn = Innovation(population, allinfects, removals, cremovals)
    chr = inn.chronology
    for i in eachindex(chr)
        @test chr[i] == [C(0.00, 1), C(0.05, 1), R(0.10, 2), R(0.20, 3), P(0.70, 1, 2)][i]
    end
end


## Testing creation of `SIR`, state of epidemic
@testset "EpidemicsCFTP: $(rpad(string(SIR), 23))" begin
    @test_throws DomainError SIR(0.0,-1, 2, 3)
    @test_throws DomainError SIR(0.0,-1, 2, 3)
    @test_throws DomainError SIR(0.0, 1,-2, 3)
    @test_throws DomainError SIR(0.0, 1, 2,-3)
    @test_throws DomainError SIR(0.0, 0, 0, 0)
    @test_throws DomainError SIR(0.0, 1,-2, 3, 2)
    @test_throws DomainError SIR(0.0, 1, 2,-3, 0)
    @test_throws DomainError SIR(0.0, 0, 0, 0, 0)
    @test_throws DomainError SIR(0.0, 1, 1, 1, 2)
    @test_throws DomainError SIR(0.0, 1, 1, 1, 1)
    sir = SIR(0.0, 1, 2, 3)
    @test sir.n == sir.s + sir.i + sir.r
end
