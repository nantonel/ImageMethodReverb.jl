#spherical grid using Fibonacci lattice
immutable SphFib <:AbstractCartPos
	pos::Array{Float64}
	xc::Array{Float64,1}  #center of the array
	r::Float64            #radius of array
	Nm::Int64             #num ofpoints 
	X::Float64            #maximum nearest neighbour distance
	θ::Array{Float64,1}   #azimuthal angle
	ϕ::Array{Float64,1}   #polar angle
	function SphFib(xc,r,Nm)
		if Nm<0 error("Nm must be greater than 0") end

		z = zeros(Float64,Nm)
		θ = zeros(Float64,Nm)
		Δz = 2./Nm               #step in z  
		Δθ = π * (3. - sqrt(5.)) #golden angle
		z[1] = 1-Δz/2            #initialize z with offset 
		#z is cos(ϕ)
	
		for i in 2:Nm
			θ[i] = θ[i-1]+Δθ
			θ[i] = mod(θ[i],2*π) 
			z[i] = z[i-1]-Δz
		end
		ϕ = acos(z)

		x = cos(θ) .* sin(ϕ)
		y = sin(θ) .* sin(ϕ)
		pos = r.*[x y z]'.+xc #multiply by radius and translate to center
		X = max_nearest_neigh(Nm,pos)

		new(pos,xc,r,Nm,X,θ,ϕ)
	end

end

#TODO make this more efficient
function max_nearest_neigh(Nm::Int64,pos::Array{Float64,2})

	d = zeros(Nm,Nm)
	for i = 1:Nm, ii = 1:Nm
		d[i,ii] = norm(pos[:,i]-pos[:,ii])
	end
	d = d+Inf*speye(Nm,Nm)
	d = sort(d,1)
	X = maximum(d[1,:]')
	return X
end

function Base.show(io::IO, f::SphFib)

		
	println("Spherical Fibonacci Lattice")
	@printf("radius                 : %.2f m \n",f.r)
	@printf("center of array        : [x;y;z] = [%.2f;%.2f;%.2f]\n",f.xc[1],f.xc[2],f.xc[3])
	println("number of pos          : $(f.Nm)")
	@printf("max nearest neigh dist : %.1e \n",f.X)
 
	
end
