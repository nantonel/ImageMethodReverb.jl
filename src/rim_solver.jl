export rim
"""
`h, seed = rim([s,] xs, xr, L, T60, Nt, Fs)`

Randomized Image Source Method

#### Arguments: 

* `s`   : (Optional) Source signals
* `xs`  : Source position in meters (must be a Tuple)
* `xr`  : Microphone position in meters (must be a `Tuple` or a `Vector{Tuple}` for mic array)
* `Nt`  : Time samples
* `L`   : 3 element `Tuple` containing dimensions of the room 
* `beta`/`T60` : 6 element `Tuple` containing reflection coefficients of walls/reverberation time
* `Nt`  : length of the RIR
* `Fs`  : sampling frequency

#### Keyword Arguments:

* `c = 343`    : speed of sound 
* `Rd = 1e-2`  : random displacement (in meters)
* `N = (0,0,0)`: 3 element `Tuple` representing order of reflection when `N == (0;0;0)` full order is computed.
* `Tw = 20`    : taps of fractional delay filter
* `Fc = 0.9`   : cut-off frequency of fractional delay filter


#### Outputs: 
* `h`: vector or matrix where each column is an impulse response or the sound pressure if `s` was specified corresponding to the microphone positions `xr`
* `seed`: randomization seed to preserve spatial properties when other RIR at different position are needed
"""
function rim(xs::NTuple{3,Number},
             xr::NTuple{3,Number},
             L::NTuple{3,Number},
             beta::NTuple{6,Number},
             Nt::Integer,
             Fs::Number;
             c::Number = 343,
             Rd::Number = 1e-2,
             seed::Integer = 1234,
             N::NTuple{3,Integer} = (0,0,0), 
             Tw::Integer = 20,
             Fc::Number = 0.9)
	     
    if any( xs .> (L[1], L[2], L[3]) ) || any( xs .<  (0;0;0) ) 
        error("xs outside domain") 
    end
    if any( xr .> (L[1], L[2], L[3]) ) || any( xr .< (0, 0 , 0) ) 
        error("xr outside domain") 
    end
    if any(N .< 0 )  
        error("N should be positive") 
    end

    Fsc = Fs/c
    L  = L.*(Fsc*2)  #convert dimensions to indices
    xr = xr.*Fsc
    xs = xs.*Fsc
    Rd = Rd *Fsc

    h = zeros(Nt)            # initialize output
    pos_is = zeros(3)
    rand_disp = zeros(3)
    if(N == (0,0,0))
      N = floor.(Int,Nt./L).+1  # compute full order
    end
    Random.seed!(seed)
    for u = 0:1, v = 0:1, w = 0:1
      for l = -N[1]:N[1], m = -N[2]:N[2], n = -N[3]:N[3]
				
        # compute distance
        pos_is[1] = xs[1]-2*u*xs[1]+l*L[1] 
        pos_is[2] = xs[2]-2*v*xs[2]+m*L[2];
        pos_is[3] = xs[3]-2*w*xs[3]+n*L[3]
        
        #position of image source
        if u+v+w+abs(l)+abs(m)+abs(n) != 0 
          rand_disp .= Rd.*(2 .*rand(3).-1)
        else
          rand_disp .*= 0  
        end
        d = norm(pos_is + rand_disp .-xr)+1

        # when norm(sum(abs( [u,v,w,l,m,n])),0) == 0 
        # we have direct path, so
        # no displacement is added

        # instead of moving the source on a line
        # as in the paper, we are moving the source 
        # in a cube with 2*Rd edge
        
        if (round(Int64,d) > Nt || round(Int64,d) < 1)
          #if index not exceed length h
          continue
        end
				
        A = prod(beta.^abs.([l-u,l,m-v,m,n-w,n]))/(4*π*(d-1))
        if Tw == 0 
          indx = round(Int64,d) #calculate index  
          s = 1
          h[indx] += s*A
        else
          indx = maximum([ceil(Int64,d.-Tw/2),1]):minimum([floor(Int64,d.+Tw/2),Nt])
          # create time window
          s = (1 .+cos.(2*π.*(indx.-d)./Tw)).*sinc.(Fc.*(indx.-d))./2
          # compute filtered impulse
          h[indx] .+= s.*A
        end
      end
    end

    h .*= Fsc
    return h, seed
end

# with T60
function rim(xs::Union{ NTuple{3,Number}, Vector{NTuple{3, Number}} },
             xr::Union{ NTuple{3,Number}, Vector{NTuple{3, Number}} },
             L::NTuple{3,Number},
             T60::Number, args...; 
             c::Number = 343,
             kwargs...)

    beta = RIM.revTime2beta(L, T60, c)
    return rim(xs, xr, L, beta, args...; kwargs...)

end

# multiple mics
function rim(xs::NTuple{3,Number},
             xr::Vector, args...;
             kwargs...)

    h = ()
    seed = 1234
    for xi in xr
        hi, seed = rim(xs, xi, args...; kwargs...)
        h = (h..., hi)
    end
    return hcat(h...), seed

end

# with source signal
function rim(s::AbstractVector,
             args...;
             kwargs...)
    h, seed = rim(args...; kwargs...)
        
    P = hcat([conv(s,h[:,i]) for i = 1:size(h,2)]...) 

    return P, seed

end

