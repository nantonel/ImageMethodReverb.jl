abstract AbstractGeometry

"""
`cuboid room object`

Returns a `cuboidRoom` object containing the geometrical information of the room.

# Arguments 

* `Lx::Float64`: x dimension of room 
* `Ly::Float64`: y dimension of room
* `Lx::Float64`: z dimension of room
* `T60::Float64`: desired T60 or `β::Array{Float64,1}` 6 element Array containg reflection coefficients of the 6 walls

by default the random displacement is set to `Rd = 1e-2`. The randomization of the image sources is saved in an internal variable of the `cuboidRoom` object in `Sr::Int64`. 

To change these default values type:

* `cuboidRoom(Lx,Ly,Lz,T60,Rd = myRd, Sr = mySr)`

"""
immutable cuboidRoom <: AbstractGeometry
	Lx::Float64   #x dimension
	Ly::Float64   #y dimension
	Lz::Float64   #z dimension
	β::Array{Float64,1}   #reflection coefficients
	Rd::Float64           #random displacement
	Sr::Int64             #seed random displacement


	#random displacement β input
	function cuboidRoom(Lx::Float64,Ly::Float64,Lz::Float64,β::Array{Float64,1};  
		            Rd::Float64 = 1e-2, Sr::Int64 = rand(1:10000) )

		if(any([Lx;Ly;Lz].< 0)) error("room dimensions L should be positive") end
		if(length(β)!= 6) error("length(β) must be 6") end
		new(Lx,Ly,Lz,β,Rd,Sr)
	end

	#random displacement T60 input
	function cuboidRoom(Lx::Float64,Ly::Float64,Lz::Float64,T60::Float64;
		            Rd::Float64 = 1e-2, Sr::Int64 = rand(1:10000) )

		if(any([Lx;Ly;Lz].< 0)) error("room dimensions L should be positive") end
		β = get_β(Lx,Ly,Lz,T60)
		new(Lx,Ly,Lz,β,Rd,Sr)

	end


end

#calculate β using Eyring equation
function get_β(Lx::Float64,Ly::Float64,Lz::Float64,T60::Float64)
		
	if(T60 < 0) error("T60 should be positive") end
	S = 2*( Lx*Ly+Lx*Lz+Ly*Lz ) # Total surface area
	V = prod([Lx;Ly;Lz])
	α = -10^(-0.161*V/(T60*S))+1 # Absorption coefficient
	β =-sqrt(abs(1-α)).*ones(6) # Reflection coefficient
	return β
end
