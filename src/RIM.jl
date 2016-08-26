__precompile__()

module RIM

abstract LinearAcoustics
abstract AcousticEnvironment <:LinearAcoustics


include("acenvironment.jl")
include("acgeometry.jl")
include("acpos.jl")
include("acrim.jl")


end
