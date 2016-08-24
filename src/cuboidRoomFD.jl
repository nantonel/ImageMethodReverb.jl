"""
`cuboid room object with Frequency Dependent absorption coefficients`

Returns a `cuboidRoom` object containing the geometrical information of the room.

# Arguments 

* `Lx::Float64`: x dimension of room 
* `Ly::Float64`: y dimension of room
* `Lx::Float64`: z dimension of room
* `b::Array{Float64}`: array containing a coefficients of Infinite Impulse Response of β
* `a::Array{Float64}`: array containing b coefficients of Infinite Impulse Response of β
* `NT::Int64`: truncation of convolution between fracional delay and β IIR

by default the random displacement is set to `Rd = 1e-2`. The randomization of the image sources is saved in an internal variable of the `cuboidRoom` object in `Sr::Int64`. 

To change these default values type:

* `cuboidRoom(Lx,Ly,Lz,T60,Rd = myRd, Sr = mySr)`

"""
immutable CuboidRoomFD <: AbstractGeometry
	Lx::Float64   #x dimension
	Ly::Float64   #y dimension
	Lz::Float64   #z dimension
	b::Array{Float64,2}     #b coefficients infinite impulse response of filter β
	a::Array{Float64,2}     #a coefficients infinite impulse response of filter β
	NT::Int64               #truncation of IIR
	Rd::Float64              #random displacement
	Sr::Int64                #seed random displacement


	#random displacement single βfir input
	function CuboidRoomFD(Lx::Float64,Ly::Float64,Lz::Float64,
		              b::Array{Float64,1},a::Array{Float64,1},NT::Int64;  
		              Rd::Float64 = 1e-2, Sr::Int64 = rand(1:10000) )
		if(any([Lx;Ly;Lz].< 0)) error("room dimensions L should be positive") end
		new(Lx,Ly,Lz,repmat(b,1,6),repmat(a,1,6),NT,Rd,Sr)
	end
	#random displacement single βfir input
	function CuboidRoomFD(Lx::Float64,Ly::Float64,Lz::Float64,
		              b::Array{Float64,2},a::Array{Float64,2},NT::Int64;  
		              Rd::Float64 = 1e-2, Sr::Int64 = rand(1:10000) )
		if(any([Lx;Ly;Lz].< 0)) error("room dimensions L should be positive") end
		if(size(b,1) != 6 || size(a,1) != 6) 
			error("size of βfir must be either (n,) or (n,6)") 
		end
		new(Lx,Ly,Lz,b,a,NT,Rd,Sr)
	end


end
