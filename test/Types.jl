# Tests for types of `EpidemicsCFTP`

using EpidemicsCFTP
using Test

## Testing `AbstractMarker`
@testset "EpidemicsCFTP: AbstractMarker" begin
    for inc in [MarkerInfectionA, MarkerRemovalA, MarkerInfectionB, MarkerRemovalB, 
                 InitialSusceptible, InitialRemoved, InitialInfected,
                 ContinuingSusceptible, ContinuingRemoved, ContinuingInfected]
        @test_throws DomainError    inc(0.05, -2)
        @test_throws InexactError   inc(0.05, 2.5)
        @test_throws DomainError    inc(0.05, -2.3)
    end
end

## Testing `Removal`
@testset "EpidemicsCFTP: Removal       " begin
inc1 = Removal
    @test_throws DomainError    inc1(0.05, -2)
    @test_throws DomainError    inc1(0.05, 0)
    @test_throws InexactError   inc1(0.05, 2.5)
    @test_throws DomainError    inc1(0.05, -2.3)
end

@testset "EpidemicsCFTP: CRemoval      " begin
inc2 = CRemoval
    @test_throws DomainError    inc2(0.05, -2)
    @test_throws DomainError    inc2(0.05, 0)
    @test_throws InexactError   inc2(0.05, 2.5)
    @test_throws DomainError    inc2(0.05, -2.3)
end


## Testing `Infection` and `PInfection`
@testset "EpidemicsCFTP: Infection     " begin
    for inc in [Infection, PInfection]
        @test_throws DomainError    inc(0.10,-1,-2)
        @test_throws DomainError    inc(0.10,-1, 2)
        @test_throws DomainError    inc(0.10, 1,-2)
        @test_throws DomainError    inc(0.10, 1, 0)
        @test_throws InexactError   inc(0.10, 1.5, 2)
        @test_throws InexactError   inc(0.10, 1,   2.5)
        @test_throws InexactError   inc(0.10, 1.5, 2.5)
        @test_throws DomainError    inc(0.10, 2.5, 1.5)
        @test_throws DomainError    inc(5.45, 0, 3)
        @test_throws DomainError    inc(5.45, 3, 2)
        @test_throws DomainError    inc(5.45, 2, 1)
        @test_throws DomainError    inc(5.45, 0, 3)
        @test_throws DomainError    inc(5.45, 3, 2)
    end
end

@testset "EpidemicsCFTP: Innovation    " begin
    P, I, R, C = PInfection, Infection, Removal, CRemoval
    AI = AbstractIncident

    n = 3
    infects   = I[I(0.70, 1, 2)]
    allinfects  = Union{I, P}[P(0.70, 1, 2)]
    removals  = R[R(0.20, 3), R(0.10, 2)]
    cremovals = C[C(0.00, 1), C(0.05, 1)]
    
    inn = Innovation(3, allinfects, removals, cremovals)
    @test inn.removals == R[R(0.10, 2), R(0.20, 3)]
    
    # Population size not positive
    @test_throws DomainError Innovation(0, allinfects, removals, cremovals)

    # Signature violations
    @test_throws MethodError Innovation(n, allinfects, cremovals, removals)
    @test_throws MethodError Innovation(n, removals, allinfects, cremovals)
 
    # Too many conditional removals
    @test_throws ArgumentError Innovation(n, allinfects, removals, 
            C[C(0.00, 1), C(0.01, 1), C(0.02, 1), C(0.05, 1)])
end

## Testing `SIR`, state of epidemic
@testset "EpidemicsCFTP: SIR           " begin
    @test_throws DomainError SIR(0.0,-1, 2, 3)
    @test_throws DomainError SIR(0.0, 1,-2, 3)
    @test_throws DomainError SIR(0.0, 1, 2,-3)
    @test_throws DomainError SIR(0.0, 0, 0, 0)
end


# 
# crem = CRemoval(0.15, 1, 1)
#     @test_throws ArgumentError   resample(crem, -100)
#     @test_throws MethodError     resample(crem,  100.5) # No signature available for non-integer second argument!
#     @test_throws MethodError     resample(crem, -100.5) # No signature available for non-integer second argument!
# end
# 

