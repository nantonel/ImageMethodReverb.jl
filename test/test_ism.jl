using RIM
using Base.Test
#include("../src/rim.jl")
#testing seed is preserved

Fs = 4e4                    # Sampling frequency
env = AcEnv(Fs)             # create new acoustic env with default values
Nt = round(Int64,0.6*Fs)    # Number of time samples, 0.25 secs
Lx,Ly,Lz  = 4.,4.,4.# Room dimensions
xs = [2 1.5 1]'      # Source position
s = randn(Nt,size(xs,2))
s = zeros(s)
s[1,:] = 1
xr = [1. 2. 2. ]'   # Receiver position

T60 = .5           # Reverberation Time
geo = CuboidRoom(Lx,Ly,Lz,T60,env)
#test printing
show(geo)

Tw = 20              # samples of Low pass filter 
Fc = 0.9             # cut-off frequency

println("testing β for a given T60 gives correct T60")
@time h  = rim(xs,xr,Nt,geo,env)
rt,edc = revTime(h,env)
@test norm(rt-T60)/norm(T60)< 0.25 #testing rev time

println("testing seed for randomization is preserved and multi source")
xr = LinearGrid([Lx/2;Ly/2;Lz/2],[0.5],3) #3 mic linear array positioned at the center of the room
xs = SphFib([Lx/2;Ly/2;Lz/2],0.9*Lz/2,5)
s = randn(Nt,xs.Nm)
@time h = rim(s,xs,xr,Nt,geo,env;N=[3;3;3])
## generate another IR with same randomization and
h2 = zeros(Nt,xr.Nm)
for i = 1:xs.Nm 
	hh = rim(xs.pos[:,i],xr,Nt,geo,env;N=[3;3;3])
	for ii = 1:xr.Nm
		h2[:,ii] += conv(s[:,i],hh[:,ii])[1:Nt]
	end
end
@test norm(h[:]-h2[:]) < 1e-8

## original image source method
println("test with no frac delay")
xs = [1.;1.;1.]
xr = [2 1.5 1]'      # Source position
@time h2 = rim(xs,xr,Nt,geo,env; Tw = 0, Fc = 0., N = [4;4;4])

#using PyPlot
#t = linspace(0,Nt*1/Fs,Nt)
#f = linspace(0,Fs,Nt)
#figure()
#subplot(2,2,1)
#plot(t,h)
#subplot(2,2,2)
#plot(t,h2)
#subplot(2,2,3)
#plot(f,10.*log10(abs(fft(h))))
#xlim([0,500])
#subplot(2,2,4)
#plot(f,10.*log10(abs(fft(h2))))
#xlim([0,500])

