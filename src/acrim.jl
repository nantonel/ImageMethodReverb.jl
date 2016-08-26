export rim

include("rim_solvers/rim_solver.jl")
include("rim_solvers/rim_fd_solver.jl")

rim(xs::Array{Float64},xr::Array{Float64},Nt::Int64, args...; kwargs...) = 
rim(CartPos(xs),CartPos(xr),Nt, args...; kwargs...)

rim(xs::AbstractCartPos,xr::Array{Float64},Nt::Int64, args...; kwargs...) = 
rim(xs,CartPos(xr),Nt, args...; kwargs...)

rim(xs::Array{Float64},xr::AbstractCartPos,Nt::Int64, args...; kwargs...) = 
rim(CartPos(xs),xr,Nt, args...; kwargs...)

#multichannel source with give input signal
function rim(s::Array{Float64},
	     xs::AbstractCartPos,xr::AbstractCartPos,Nt::Int64, 
	     geo::AbstractGeometry,env::AcEnv; kwargs...)
	if size(s,2) != xs.Nm error("size(s,2) must have same size of sources") end 
	h = zeros(Float64,Nt,xr.Nm)
	for i = 1:xs.Nm
		h2 = rim(xs.pos[:,i],xr,Nt,geo,env;kwargs...)
		for ii = 1:size(xr.pos,2)
			h[:,ii] += conv(s[:,i],h2[:,ii])[1:Nt]
		end
	end
	return h 
end


rim(s::Array{Float64}, xs::Array{Float64},xr::Array{Float64},Nt::Int64, args...; kwargs...) = 
rim(s,CartPos(xs),CartPos(xr),Nt, args...; kwargs...)

rim(s::Array{Float64},xs::AbstractCartPos,xr::Array{Float64},Nt::Int64, args...; kwargs...) = 
rim(s,xs,CartPos(xr),Nt, args...; kwargs...)

rim(s::Array{Float64},xs::Array{Float64},xr::AbstractCartPos,Nt::Int64, args...; kwargs...) = 
rim(s,CartPos(xs),xr,Nt, args...; kwargs...)
