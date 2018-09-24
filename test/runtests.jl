using RIM
using Test
using LinearAlgebra
using DSP
using DelimitedFiles, Random

@testset "RIM" begin

    @testset "Geometry definitions" begin 
        include("test_acgeometry.jl")
    end

    @testset "Image source method" begin 
        include("test_ism.jl")
    end

    @testset "equivalence with MATLAB" begin 
        include("test_julia_vs_matlab.jl")
    end

    @testset "frequency dependant IM" begin 
        include("test_ismfd.jl")
    end

end
