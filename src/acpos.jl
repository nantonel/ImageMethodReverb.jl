export LinearGrid
#TO DO add rotations

immutable CartPos <:AbstractCartPos
	pos::Array{Float64}
	CartPos(pos) = size(pos,1)!=3 ? error("size(pos,1) must be 3"): new(pos)
end

immutable LinearGrid <:AbstractCartPos
	pos::Array{Float64}
	xc::Array{Float64,1} #center of the array
	Nx::Int64            #mics on x direction
	Ny::Int64            #mics on y direction
	Nz::Int64            #mics on z direction
	X::Float64           #distance between mics
	Y::Float64           #distance between mics
	Z::Float64           #distance between mics
	function LinearGrid(pos,xc,Nx,Ny,Nz,X,Y,Z)
		if size(pos,1)!=3 error("size(pos,1) must be 3") end
		if size(xc,1)!=3 error("size(xc,1) must be 3") end
		if Nx<0 error("Nx must be greater than 0") end
		if Ny<0 error("Ny must be greater than 0") end
		if Nz<0 error("Nz must be greater than 0") end
		if X<0  error("X must be positive") end
		if Y<0  error("Y must be positive") end
		if Z<0  error("Y must be positive") end
		new(pos,xc,Nx,Ny,Nz,X,Y,Z)
	end

end

function LinearGrid(xc::Array{Float64,1},
		    lx::Float64,ly::Float64,lz::Float64, 
		    X::Float64,Y::Float64,Z::Float64)

	x = collect(0:X:lx)
	y = collect(0:Y:ly)
	z = collect(0:Z:ly)
	Nx,Ny,Nz = length(x),length(y),length(z)
	pos =[repmat([repmat(x,Ny) repmat(y,1,Nx)'[:]],Nz) repmat(z,1,Nx*Ny)'[:]]' 
	pos = pos.+(xc-[lx/2;ly/2;lz/2])

	LinearGrid(pos,xc,Nx,Ny,Nz,X,Y,Z)

end
##with same discretization X
LinearGrid(xc::Array{Float64,1},lx::Float64,ly::Float64,lz::Float64, X::Float64) = 
LinearGrid(xc,lx,ly,lz,X,X,X)
#plane
LinearGrid(xc::Array{Float64,1},lx::Float64,ly::Float64,X::Float64) = LinearGrid(xc,lx,ly,0.,X,X,X)
#line
LinearGrid(xc::Array{Float64,1},lx::Float64,X::Float64) = LinearGrid(xc,lx,0.,0.,X,X,X)

function LinearGrid(xc::Array{Float64,1},
		    l::Array{Float64,1}, #vector containing length of array
		    Nx::Int64,Ny::Int64,Nz::Int64)

	if length(l) > 3 error("l must be at least 3 element array") end
	if length(l) == 2 l = [l;0.] end
	if length(l) == 1 l = [l;0.;0.] end

	x = linspace(0,l[1],Nx); X = x[2]
	if(l[2] != 0) y = linspace(0,l[2],Ny); Y = y[2] else y,Ny = [0.],1; Y = 0. end
	if(l[3] != 0) z = linspace(0,l[3],Nz); Z = z[2] else z,Nz = [0.],1; Z = 0. end

	pos =[repmat([repmat(x,Ny) repmat(y,1,Nx)'[:]],Nz) repmat(z,1,Nx*Ny)'[:]]' 
	pos = pos.+(xc-[l[1]/2;l[2]/2;l[3]/2])

	LinearGrid(pos,xc,Nx,Ny,Nz,X,Y,Z)

end


LinearGrid(xc::Array{Float64,1},l::Array{Float64,1},Nx::Int64) = LinearGrid(xc,l,Nx,Nx,Nx)













