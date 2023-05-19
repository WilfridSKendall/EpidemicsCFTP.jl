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


@testset "EpidemicsCFTP: chronology" begin
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
