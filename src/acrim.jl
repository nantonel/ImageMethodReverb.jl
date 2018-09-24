export rim

include("rim_solvers/rim_solver.jl")
include("rim_solvers/rim_fd_solver.jl")

#multichannel source with give input signal
function rim(s::AbstractArray,
	     xs::AbstractArray,xr::AbstractArray,Nt::Int64, 
	     geo::AbstractGeometry,env::AcEnv; kwargs...)
	if size(s,2) != size(xs,2) error("size(s,2) must have same size of sources") end 
	h = zeros(Float64,Nt,size(xr,2))
	for i = 1:size(xs,2)
		h2 = rim(xs[:,i],xr,Nt,geo,env;kwargs...)
		for ii = 1:size(xr,2)
			h[:,ii] += conv(s[:,i],h2[:,ii])[1:Nt]
		end
	end
	return h 
end

