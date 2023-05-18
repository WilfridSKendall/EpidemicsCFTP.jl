# Tests for `EpidemicsCFTP`

## Testing `isless`
@testset "EpidemicsCFTP: isless    " begin
    @test   Removal(0.10, 2)  < Removal(0.5, 3)
    @test   Removal(0.5, 3)   < Removal(0.90, 2)
    @test   CRemoval(0.10, 2) < Removal(0.5, 3)
    @test   Removal(0.5, 3)   < CRemoval(0.90, 2)
    @test   CRemoval(0.10, 2) < CRemoval(0.5, 3)
    @test   CRemoval(0.5, 3)  < CRemoval(0.90, 2)
    @test   Infection(0.10, 1, 2) < Infection(0.5, 1, 3)
    @test !(Infection(0.70, 1, 2) < Infection(0.5, 1, 3))
    @test   Infection(0.10, 1, 2) < Removal(0.5, 3)
end

