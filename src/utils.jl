export revTime

"""
`revTime(h::AbstractVector, Fs::Number)`

Returns the T60 of the impulse response `h` with sampling frequency `Fs`.
"""
function revTime(h::AbstractVector,Fs::Number)

  cs = cumsum(reverse(h.^2, dims = 1), dims = 1)
  edc = 10*log10.(reverse(cs./cs[end], dims = 1)) #energy decay curve

  rt = zeros(Float64,size(h,2))
  for i = 1:size(h,2)
    ind = findfirst(edc[:,i] .<= -60. )
    if ind == 0 
      rt[i] = size(h,1)/Fs 
    else
      rt[i] = ind/Fs
    end
  end

  return rt, edc

end

"""
`revTime2beta( (Lx,Ly,Lz), T60, c = 343)`

Given the reverberation time in T60 in a cuboid room with volume `Lx` x `Ly` x `Lz` returns a 6-long vector containing the reflection coefficients (β) of each wall surface.
"""
function revTime2beta(L, T60, c)

  if(T60 < 0) error("T60 should be positive") end
  Lx, Ly, Lz = L
  S = 2*( Lx*Ly+Lx*Lz+Ly*Lz ) # Total surface area
  V = prod([Lx;Ly;Lz])
  α = 1-exp(-(24*V*log(10))/(c*T60*S)) # Absorption coefficient
  β =-sqrt(abs(1-α)).*ones(6) # Reflection coefficient
  return β

end

