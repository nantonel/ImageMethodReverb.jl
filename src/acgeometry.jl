export CuboidRoom,
       CuboidRoomFD 

abstract AbstractGeometry    <:LinearAcoustics

include("cuboidRoom/cuboidRoom.jl")
include("cuboidRoom/cuboidRoomFD.jl")

function Base.show(io::IO, f::AbstractGeometry)

	println(io, "geometry    : ", fun_name(f))
	println(io, "dimensions  : ", fun_dim(f))
	println(io, "β           : ", fun_β(f))
	println(io, "Rd          : ", fun_Rd(f))
	
end
