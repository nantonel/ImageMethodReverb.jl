using ImageMethodReverb
using Test
using LinearAlgebra
using DSP
using DelimitedFiles, Random

@testset "ImageMethodReverb" begin

    @testset "Image source method" begin 
        include("test_ism.jl")
    end
    @testset "equivalence with MATLAB" begin 
        include("test_julia_vs_matlab.jl")
    end

end
