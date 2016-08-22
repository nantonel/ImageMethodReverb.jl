"""
Randomized Image Source Method

# Arguments: 

* `Fs::Float64`         : Sampling Frequency 
* `c::Float64`          : Speed of sound
* `xr::Array{Float64}`  : Microphone positions (in meters) (3 by Nm Array) where Nm is number of microphones
* `xs::Array{Float64}`  : source positions (in meters) (must be a 3 by 1 Array)
* `L::Array{Float64,1}` : room dimensions  (in meters), must be a 3 dimensional Array
* `β`                   : if a 6 element Array is given each element 
                          represents the reflectlion coefficient of a wall, 
                          if a 1 element Array is given instead this represents 
                          the T60 and all the walls have the same reflection coefficients 
                          Nt samples of impulse response


# Optional parameters:

* `N:Array{Int64,1} = [0;0;0]`: 3 element Array representing order of reflection 
                                (set to [0;0;0] to compute full order).
* `Rd::Float64 = 1e-2`        : random displacement of image sources (in meters).
* `Sr = []`                   : seed of the random sequence (set to [] if you want to compute a new randomization). 
* `Tw::Int64 = 20`            : taps of fractional delay filter
* `Fc::Float64 = 0.9`         : cut-off frequency of fractional delay filter


# Outputs: 
* `h::Array{Float64}`: `h` is a matrix where each column 
		       corresponts to the impulse response of 
		       the microphone positions `xr`
* `Sr::Int32`        : seed for the randomization (to be saved if a different RIM simulation is run with the same randomization. 
"""

function rim(Fs::Float64,c::Float64,xr::Array{Float64},xs::Array{Float64},
	     L::Array{Float64,1},β,Nt::Int64;
	     N::Array{Int64,1} = [0;0;0],Rd::Float64 = 1e-2, Sr = [],Tw::Int64 = 20,Fc::Float64 =0.9)
	     
	if(Fs< 0) error("Fs should be positive") end
	if(c< 0)  error("c should be positive") end
	if(size(xr,1)!=3)  error("size(xr,1) must be 3") end
	if(size(xs)!=(3,)) error("size(xr,1) must be (3,1)") end
	if(any(L.< 0)) error("L should be positive") end
	if(any(N.< 0)) error("N should be positive") end

	if(length(β) == 1)  # T60 is in input and is converted to β 
		S = 2*( L[1]*L[2]+L[1]*L[3]+L[2]*L[3] ) # Total surface area
		V = prod(L)
		α = -10^(-0.161*V/(β*S))+1 # Absorption coefficient
		β =-sqrt(abs(1-α)).*ones(6) # Reflection coefficient
	end

	L  =  L./c*Fs*2  #convert dimensions to indices
	xr = xr./c*Fs
	xs = xs./c*Fs
	Rd = Rd./c*Fs

	K = size(xr,2)        #number of microphones

	h = zeros(Nt,K)            # initialize output


	if(N == [0,0,0])
		N = floor(Int64,Nt./L)+1  # compute full order
	end

	if(isempty(Sr)) # compute new randomization of image sources
	Sr = ccall( (:clock, "libc"), Int32, ()) #obtain a new seed from clock
        end


	for k = 1:K
	
		srand(Sr)
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

				if(Tw == 0)
					indx = round(Int64,d) #calculate index  
					s = 1
				else
					indx = (
				maximum([ceil(Int64,d-Tw/2),1]):minimum([floor(Int64,d+Tw/2),Nt])
				               )
					# create time window
					s = (1+cos(2*π*(indx-d)/Tw)).*sinc(Fc*(indx-d))/2
					# compute filtered impulse
				end
	
				A = prod(β.^abs([l-u,l,m-v,m,n-w,n]))/(4*π*(d-1))
				h[indx,k] = h[indx,k] + s.*A
			end
		end
	end

return h.*(Fs/c), Sr

end
