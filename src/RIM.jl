__precompile__()

module RIM

abstract LinearAcoustics
abstract AcousticEnvironment <:LinearAcoustics


include("acenvironment.jl")
include("acgeometry.jl")
include("acpos.jl")
include("rim_solver.jl")
include("rim_fd_solver.jl")

rim(env::AcEnv, Nt::Int64,xr::Array{Float64},xs::Array{Float64}, args...; kwargs...) = 
rim(env,Nt,CartPos(xr),CartPos(xs), args...; kwargs...)

rim(env::AcEnv, Nt::Int64,xr::AbstractCartPos,xs::Array{Float64}, args...; kwargs...) = 
rim(env,Nt,xr,CartPos(xs), args...; kwargs...)

rim(env::AcEnv, Nt::Int64,xr::Array{Float64}, args...; kwargs...) = 
rim(env,Nt,CartPos(xr), args...; kwargs...)

export rim

end
