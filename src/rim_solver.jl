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
  beta = convert.(eltype(h), beta)
  pos_is = zeros(3)
  if( N == (0,0,0) )
    N = floor.(Int,Nt./L).+1  # compute full order
  end
  Random.seed!(seed)
  if Tw == 0
    run_rim!(h, xs, xr, pos_is, L, beta, N, Rd, Nt)
  else # with fractional delay
    run_rim!(h, xs, xr, pos_is, L, beta, N, Rd, Fc, Tw, Nt)
  end
  h .*= Fsc
  return h, seed
end

# with fractional delay
function run_rim!(h::AbstractVector{T}, 
                  xs::X, xr::X, pos_is::AbstractVector{T}, L::X, 
                  beta::NTuple{6,T},
                  N::NN, 
                  Rd::T, Fc::T, Tw::I, Nt::I 
                 ) where {T <: AbstractFloat, I<:Integer, 
                          X <: NTuple{3,T}, NN <:NTuple{3,I}}
  beta_pow = zeros(I,6)
  for u = 0:1, v = 0:1, w = 0:1
    for l = -N[1]:N[1], m = -N[2]:N[2], n = -N[3]:N[3]
      if (l ==0 && m == 0 && n == 0 && u == 0 && v == 0 && w == 0)
        # we have direct path, so
        # no displacement is added
        RD = 0.0 
      else
        RD = Rd
      end
      # compute distance
      pos_is[1] = xs[1]-2*u*xs[1]+l*L[1] + RD*(2*rand()-1)
      pos_is[2] = xs[2]-2*v*xs[2]+m*L[2] + RD*(2*rand()-1)
      pos_is[3] = xs[3]-2*w*xs[3]+n*L[3] + RD*(2*rand()-1)
      # position of image source
        
      d = norm( pos_is .-xr )+1
      # instead of moving the source on a line
      # as in the paper, we are moving the source 
      # in a cube with 2*Rd edge
      id = round(Int64,d)
      if (id > Nt || id < 1)
        #if index not exceed length h
        continue
      end
        
      A = get_amplitude!(beta, beta_pow, l,m,n, u,v,w, d)
      add_delay!(h, d, A, Tw, Fc, Nt)
    end
  end
  return h
end

# fractional delay
function add_delay!(h::Array{T}, d::T, A::T, Tw::I, Fc::T, Nt::I) where {
                                                                  T <: AbstractFloat, 
                                                                  I <: Integer
                                                                 }
  # create time window
  indx = max(ceil(I,d.-Tw/2),1):min(floor(I,d.+Tw/2),Nt)
  # compute filtered impulse
  A2 = A/2
  @inbounds @simd for i in indx
    h[i] += A2 *( 1.0 + cos(2*π*(i-d)/Tw) )*sinc(Fc*(i-d))
  end
  return h
end

function get_amplitude!(beta::NTuple{6,T}, 
                        beta_pow::Array{I}, 
                        l::I,m::I,n::I, 
                        u::I,v::I,w::I, 
                        d::T)  where {I <: Integer, 
                                      T <: AbstractFloat}
  beta_pow[1] = abs(l-u)
  beta_pow[2] = abs(l)
  beta_pow[3] = abs(m-v)
  beta_pow[4] = abs(m)
  beta_pow[5] = abs(n-w)
  beta_pow[6] = abs(n)
  A = one(T)
  for i in eachindex(beta)
    A *= beta[i]^beta_pow[i]
  end
  A /= (4*π*(d-1))
  return A
end


# without fractional delay
function run_rim!(h::AbstractVector{T}, 
                  xs::X, xr::X, pos_is::AbstractVector{T}, L::X, 
                  beta::NTuple{6,T},
                  N::NN, 
                  Rd::T, Nt::I 
                 ) where {T <: AbstractFloat, I<:Integer, 
                          X <: NTuple{3,T}, NN <:NTuple{3,I}}
  beta_pow = zeros(I,6)
  for u = 0:1, v = 0:1, w = 0:1
    for l = -N[1]:N[1], m = -N[2]:N[2], n = -N[3]:N[3]
      if (l ==0 && m == 0 && n == 0 && u == 0 && v == 0 && w == 0)
        # we have direct path, so
        # no displacement is added
        RD = 0.0 
      else
        RD = Rd
      end
      # compute distance
      pos_is[1] = xs[1]-2*u*xs[1]+l*L[1] + RD*(2*rand()-1)
      pos_is[2] = xs[2]-2*v*xs[2]+m*L[2] + RD*(2*rand()-1)
      pos_is[3] = xs[3]-2*w*xs[3]+n*L[3] + RD*(2*rand()-1)
      # position of image source
        
      d = norm(pos_is .-xr)+1
      # instead of moving the source on a line
      # as in the paper, we are moving the source 
      # in a cube with 2*Rd edge
      id = round(Int64,d)
      if (id > Nt || id < 1)
        #if index not exceed length h
        continue
      end
        
      A = get_amplitude!(beta, beta_pow, l,m,n, u,v,w, d)
      h[id] += A
    end
  end
  return h

end

# with T60
function rim(xs::Union{ NTuple{3,Number}, Vector{NTuple{3, Number}} },
             xr::Union{ NTuple{3,Number}, Vector{NTuple{3, Number}} },
             L::NTuple{3,Number},
             T60::Number, args...; 
             c::Number = 343,
             kwargs...)

    beta = ImageMethodReverb.revTime2beta(L, T60, c)
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

