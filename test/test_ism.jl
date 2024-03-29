#testing seed is preserved
Fs = 4e4                    # Sampling frequency
c = 343                     # create new acoustic env with default values
Nt = round(Int64,0.1*Fs)    # Number of time samples, 0.25 secs
L  = (4., 4.,  4.)          # Room dimensions
Lx,Ly,Lz = L
xs = (2., 1.5, 1.)      # Source position
xr = (1., 2.,  2.)   # Receiver position

T60 = 0.1           # Reverberation Time
beta = ImageMethodReverb.revTime2beta(L, T60, c)
Tw = 20              # samples of Low pass filter 
Fc = 0.9             # cut-off frequency

println("testing β for a given T60 gives correct T60")
h, seed  = rim(xs,xr,L,beta,Nt,Fs; N = (4,4,4))
rt, edc = revTime(h, Fs)
@test norm(rt.-T60)/norm(T60)< 0.25 #testing rev time

println("testing seed is preserved")
h2,  = rim(xs,xr,L,beta,Nt,Fs; N = (4,4,4), seed = seed)
@test norm(h-h2) < 1e-8

println("testing calls")
# with T60
h2,  = rim(xs,xr,L,T60,Nt,Fs; N = (4,4,4), seed = seed)
@test norm(h-h2) < 1e-8

## original image source method
println("test with no fractional delay")
xs = (2., 1.5, 1.)      # Source position
xr = (1., 2.,  2.)   # Receiver position
h2, = rim(xs,xr,L,beta,Nt,Fs; Tw = 0, Fc = 0., N = (4,4,4), seed = seed)

println("test line of sight")
xs = (1., 1., 1.)
for i = 1:10
  d = (0.2 .*randn(3)...,) # dandom dispacement
  h_rand, = rim(xs, xs .+ d, L, 0.001, Nt,Fs; Rd = 1e-1, N = (0,0,0))
  @test argmax(h_rand)*1/Fs - norm(xr .- xs)/343 < 1e-4
end

# testing errors
L, xr, xs = (1,1,1), (0.5,0.5,0.5),(0.7,0.7,0.7)
@test_throws ErrorException rim((0.1,), xr, L, beta, Nt,Fs)
@test_throws ErrorException rim((1.1,0,0), xr, L, beta, Nt,Fs)
@test_throws ErrorException rim(xs,(0.1,), L, beta, Nt,Fs)
@test_throws ErrorException rim(xs,(1.1,0,0), L, beta, Nt,Fs)
@test_throws ErrorException rim(xs,xr,(0,0), beta, Nt,Fs)
@test_throws ErrorException rim(xs,xr,L, beta, Nt,Fs; N=(-1,1,1))
@test_throws ErrorException rim(xs,xr,L, beta, Nt,Fs; N=(1,1))
@test_throws ErrorException rim(xs,xr,L, beta, Nt,Fs; N=(1,1))
@test_throws ErrorException rim(xs,xr,L, beta, Nt,Fs; N=(1.5,1,1))
@test_throws ErrorException rim(xs,xr,L, (1,1), Nt,Fs)
