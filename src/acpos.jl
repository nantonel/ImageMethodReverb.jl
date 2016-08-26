export LinearGrid, SphFib

abstract AbstractCartPos     <:LinearAcoustics

immutable CartPos <:AbstractCartPos
	pos::Array{Float64}
	CartPos(pos) = size(pos,1)!=3 ? error("size(pos,1) must be 3"): new(pos)
end

include("acpos/LinearGrid.jl")
include("acpos/SphericalGrid.jl")













