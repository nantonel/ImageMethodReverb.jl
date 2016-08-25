#implementation with frequency dependent boundaries

function rim(env::AcEnv,Nt::Int64,
             xr::AbstractCartPos,xs::AbstractCartPos,
	     geo::CuboidRoomFD;
	     N::Array{Int64,1} = [0;0;0], Tw::Int64 = 20,Fc::Float64 = 0.9)
	     
	if(any(xs.pos.>[geo.Lx;geo.Ly;geo.Ly]) || any(xs.pos.<[0;0;0])) error("xs outside domain") end
	if(any(xr.pos.>[geo.Lx;geo.Ly;geo.Ly]) || any(xr.pos.<[0;0;0])) error("xr outside domain") end
	if(any(N.< 0)) error("N should be positive") end
	if(Tw == 0) error("freq dep rim not implemented without fractional delays") end

	L  =  [geo.Lx;geo.Ly;geo.Ly]./env.c*env.Fs*2  #convert dimensions to indices
	xr = xr.pos./env.c*env.Fs
	xs = xs.pos./env.c*env.Fs
	Rd = geo.Rd./env.c*env.Fs

	K = size(xr,2)        #number of microphones

	h = zeros(Float64,Nt,K)            # initialize output

	if(N == [0,0,0])
		N = floor(Int64,Nt./L)+1  # compute full order
	end

	for k = 1:K
	
		srand(geo.Sr)
		for u = 0:1, v = 0:1, w = 0:1
			for l = -N[1]:N[1], m = -N[2]:N[2], n = -N[3]:N[3]
	
				# compute distance
				pos_is = [
				xs[1]-2*u*xs[1]+l*L[1]; 
				xs[2]-2*v*xs[2]+m*L[2];
				xs[3]-2*w*xs[3]+n*L[3]
				]                         #position of image source
				
				rand_disp = Rd*(2*rand(3)-1)*norm(sum(abs([u;v;w;l;m;n])),0)
				d = norm(pos_is+rand_disp-xr[:,k])+1

				# when norm(sum(abs( [u,v,w,l,m,n])),0) == 0 
				# we have direct path, so
				# no displacement is added
	
				# instead of moving the source on a line
				# as in the paper, we are moving the source 
				# in a cube with 2*Rd edge

				if(round(Int64,d)>Nt || round(Int64,d)<1)
					#if index not exceed length h
					continue
				end

				indx0 = (
				maximum([ceil(Int64,d-Tw/2),1]):minimum([floor(Int64,d+Tw/2),Nt])
				        )
				# create time window
					
				if(norm(sum(abs([u,v,w,l,m,n])),0)==0) #direct path
					s = (1+cos(2*π*(indx0-d)/Tw)).*sinc(Fc*(indx0-d))/2
					# fractional filter, no convolution with βfir
					A = 1/(4*π*(d-1))
					h[indx0,k] = h[indx0,k] + s.*A
				else
					s = (1+cos(2*π*(indx0-d)/Tw)).*sinc(Fc*(indx0-d))/2
					s = [s;zeros(Float64,max(geo.NT-Tw,1))]
					# s will be a NT+Tw long signal
					s = conv_βfir(s,geo,l,m,n,u,v,w)
					indend = max(geo.NT-Tw/2,Tw/2) #final index 
					indx = (
				maximum([ceil(Int64,d-Tw/2),1]):minimum([floor(Int64,d+indend),Nt])
				               )
					#just to be sure s and indx have same length
					s = s[1:min(length(indx),length(s))]
					indx = indx[1:length(s)]
				
					A = 1/(4*π*(d-1))
					h[indx,k] = h[indx,k] + s.*A
				end
	
			end
		end
	end

return h.*(env.Fs/env.c)

end

function conv_βfir(s::Array{Float64,1},geo::CuboidRoomFD,
		   l::Int64,m::Int64,n::Int64,u::Int64,v::Int64,w::Int64)

	w_ord    = abs([l-u,l,m-v,m,n-w,n]) #wall orders
	act_ords = find(w_ord)            #active orders

	for i = 1:length(act_ords) #for all active orders
		for ii = 1:w_ord[act_ords[i]] #convolve s up to max order
			filt!(s,geo.b[:,i][:],geo.a[:,i][:],s)
		end
	end
	return s

end





















