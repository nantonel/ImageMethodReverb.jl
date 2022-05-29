export rim
"""
`h, seed = rim(xs, xr, L, T60, Nt, Fs)`

Computes a synthetic acoustic room impulse response (RIR).

#### Arguments: 

* `xs`  : source position (m)
* `xr`  : microphone position (m)
* `L`   : room dimensions (m)
* `beta`/`T60` : 6 element containing reflection coefficients of walls/reverberation time
* `Nt`  : length of the RIR (samples)
* `Fs`  : sampling frequency (Hz)

#### Keyword Arguments:

* `c = 343`    : speed of sound (m/s)
* `Rd = 1e-1`  : random displacement (m)
* `N = (0,0,0)`: 3 element representing order of reflection when `N == (0,0,0)` full order is computed.
* `Tw = 20`    : taps of fractional delay filter (samples)
* `Fc = 0.9`   : cut-off frequency of fractional delay filter (samples)
* `T=Float64`  : data type


#### Outputs: 
* `h`: vector or matrix where each column is an impulse response or the sound pressure if `s` was specified corresponding to the microphone positions `xr`
* `seed`: randomization seed to preserve spatial properties when other RIR at different position are needed
"""
function rim(xs,
             xr,
             L,
             beta,
             Nt::Int,
             Fs;
             c = 343,
             Rd = 8e-2,
             seed = 1234,
             N = (0,0,0), 
             Tw = 20,
             Fc = 0.9,
             T = Float64,
            )

  if length(xs) != 3
    throw(ErrorException("length(xs) must be equal to 3"))
  end
  if length(xr) != 3
    throw(ErrorException("length(xr) must be equal to 3"))
  end
  if length(L) != 3
    throw(ErrorException("length(L) must be equal to 3"))
  end
  if length(N) != 3
    throw(ErrorException("length(L) must be equal to 3"))
  end

  if any( xs .> L ) || any( xs .<  0 ) 
    throw(ErrorException("xs outside of room"))
  end
  if any( xr .> L ) || any( xr .< 0 ) 
    throw(ErrorException("xr outside of room"))
  end
  if any(N .< 0 )  
    throw(ErrorException("N should be positive"))
  end
  if any( (typeof(n) <: Int) == false for n in N  )
    throw(ErrorException("N should be integers only"))
  end
  if length(beta) == 1 # T60
    beta = revTime2beta(L, beta, c)
  end
  if length(beta) != 6  
    throw(ErrorException("beta must be either of length 1 or 6"))
  end

  Fsc = T(Fs/c)
  L  = Array{T}([L.*(Fsc*2)...])  # remove units
  xr = Array{T}([xr.*Fsc...])
  xs = Array{T}([xs.*Fsc...])
  beta = Array{T}([beta...])
  N = [N...]
  Rd = T(Rd *Fsc)

  h = zeros(T,Nt)            # initialize output
  pos_is = zeros(T,3)
  if( all(N .== 0) )
    N = floor.(Int, Nt./L).+1  # compute full order
  end
  Random.seed!(seed)
  run_rim!(h, xs, xr, pos_is, L, beta, N, T(Rd), Fc, Tw, Nt)
  h .*= Fsc
  return h, seed
end

# with fractional delay
function run_rim!(h::V, 
                  xs::V,
                  xr::V,
                  pos_is::V,
                  L::V, 
                  beta::V,
                  N::VI, 
                  Rd::T,
                  Fc::T,
                  Tw::I,
                  Nt::I, 
                 ) where {T <: AbstractFloat, 
                          V <: AbstractArray{T}, 
                          I <: Integer, 
                          VI <: AbstractArray{I}, 
                         }
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
      pos_is[1] = xs[1]-2*u*xs[1]+l*L[1]+RD*randn()
      pos_is[2] = xs[2]-2*v*xs[2]+m*L[2]+RD*randn() 
      pos_is[3] = xs[3]-2*w*xs[3]+n*L[3]+RD*randn() 
      # position of image source

      d = norm( pos_is .-xr )+1 + Rd
      id = round(Int64,d)
      if (id > Nt || id < 1)
        #if index not exceed length h
        continue
      end

      A = get_amplitude!(beta, beta_pow, l,m,n, u,v,w, d)
      if Tw == 0
        h[id] += A
      else
        add_sinc_delay!(h, d, A, Tw, Fc, Nt)
      end
    end
  end
  return h
end

# fractional delay
function add_sinc_delay!(h::Array{T}, 
                    d::T, 
                    A::T, 
                    Tw::I, 
                    Fc::T, 
                    Nt::I) where {T <: AbstractFloat, I <: Integer}
  # create time window
  indx = max(ceil(I,d.-Tw/2),1):min(floor(I,d.+Tw/2),Nt)
  # compute filtered impulse
  A2 = A/2
  @inbounds @simd for i in indx
    h[i] += A2 *( 1.0 + cos(2*π*(i-d)/Tw) )*sinc(Fc*(i-d))
  end
  return h
end

function get_amplitude!(beta::Array{T}, 
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
