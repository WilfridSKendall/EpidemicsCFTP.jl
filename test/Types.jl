# Tests for types of `EpidemicsCFTP`

using EpidemicsCFTP
using Test

## Testing `Removal`
@testset "EpidemicsCFTP: Removal   " begin
inc1 = Removal
    @test_throws DomainError    inc1(0.05, -2)
    @test_throws DomainError    inc1(0.05, 0)
    @test_throws InexactError   inc1(0.05, 2.5)
    @test_throws DomainError    inc1(0.05, -2.3)
end

@testset "EpidemicsCFTP: CRemoval  " begin
inc2 = CRemoval
    @test_throws DomainError    inc2(0.05, -2)
    @test_throws DomainError    inc2(0.05, 0)
    @test_throws InexactError   inc2(0.05, 2.5)
    @test_throws DomainError    inc2(0.05, -2.3)
end


## Testing `Infection` and `PInfection`
@testset "EpidemicsCFTP: Infection " begin
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

# ## Testing `isless`
# @testset "EpidemicsCFTP: isless    " begin
#     @test   SIR(0.0, 1, 2, 1)     < SIR(0.5, 0, 3, 1)
#     @test !(SIR(0.0, 1, 2, 1)     < SIR(0.0, 0, 3, 1))
#     @test   Removal(0.5, 3)       < Infection(0.90, 1, 2)
#     @test   RightCensor(0.5)      < Infection(0.90, 1, 2)
#     @test   RightCensor(1.5)      > Infection(0.90, 1, 2)
# end=#


# 
# crem = CRemoval(0.15, 1, 1)
#     @test_throws ArgumentError   resample(crem, -100)
#     @test_throws MethodError     resample(crem,  100.5) # No signature available for non-integer second argument!
#     @test_throws MethodError     resample(crem, -100.5) # No signature available for non-integer second argument!
# end
# 
# ## Testing `SIR`, state of epidemic
# @testset "EpidemicsCFTP: SIR       " begin
#     @test_throws DomainError SIR(0.0,-1, 2, 3)
#     @test_throws DomainError SIR(0.0, 1,-2, 3)
#     @test_throws DomainError SIR(0.0, 1, 2,-3)
#     @test_throws DomainError SIR(0.0, 0, 0, 0)
# end
# 
