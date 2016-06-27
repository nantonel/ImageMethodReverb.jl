function ISM(xr,xs,L,β,N,Nt,Rd,Sr,Tw,Fc,Fs,c)
#=
Image Source Method simulator

Inputs: xr microphone positions (in meters) (3 element array)
           xr = [xr,yr,zr]
        xs source position (in meters)
           xs = [xs,ys,zs]
	L  room dimension (in meters)
           L = [Lx,Ly,Lz]
	β  absorption coefficient 
	   (6 element array)
           or T60 if 1 element array 
	N  order of reflections 
	   (set to [0,0,0] to compute full order)
	Nt samples of impulse response
	Rd random displacement (in meters)
	Sr seed of the random sequence
	   (set 0 if you want to compute a new one)
        Tw samples of fractional delay
	Fc cutoff frequency of fractional delay
	Fs Sampling Frequency
	c  Speed of sound
Outputs: h  impuse response
         Sr seed for the randomization
            set to 0 to generate a new one
	 (to be used if multiple IR are needed)
=#
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

	assert(size(xr,1)==3) #check that the size are correct
	K = size(xr,2)        #number of microphones

	h = zeros(Nt,K)            # initialize output


	if(N == [0,0,0])
		N = floor(Int64,Nt./L)+1  # compute full order
	end

	if(Sr == 0) # compute new randomization of image sources
	Sr = ccall( (:clock, "libc"), Int32, ()) #obtain a new seed from clock
        end


	for k = 1:K
	
		srand(Sr)
		for u = 0:1, v = 0:1, w = 0:1
			for l = -N[1]:N[1], m = -N[2]:N[2], n = -N[3]:N[3]
	
				# compute distance
				d =(norm([(2*u-1)*xs[1]+xr[1,k]-l*L[1],
				(2*v-1)*xs[2]+xr[2,k]-m*L[2],
				(2*w-1)*xs[3]+xr[3,k]-n*L[3]]
				+Rd*(2*rand(3)-1)*norm(sum(abs([u,v,w,l,m,n])),0)) 
				+1) #random displacement
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


