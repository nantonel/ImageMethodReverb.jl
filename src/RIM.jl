__precompile__()

module RIM

include("acgeometry.jl")
include("rim.jl")
include("rimfd.jl")

export rim,cuboidRoom,cuboidRoomFD

end
