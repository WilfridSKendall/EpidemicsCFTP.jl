using EpidemicsCFTP
using Test

@testset "EpidemicsCFTP.jl" begin
    @test EpidemicsCFTP.greet_EpidemicsCFTP() == nothing
    @test EpidemicsCFTP.greet_EpidemicsCFTP() != "Hello world!"
end
