__precompile__()

module RIM

abstract type LinearAcoustics end
abstract type AcousticEnvironment <:LinearAcoustics end


include("acenvironment.jl")
include("acgeometry.jl")
include("acpos.jl")
include("acrim.jl")
include("utils.jl")


end
