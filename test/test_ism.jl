using RIM
#include("../src/rim.jl")
#testing seed is preserved

Fs = 4e4            # Sampling frequency
env = AcEnv(Fs)   # create new acoustic env with default values
Nt = round(Int64,4E4/4)    # Number of time samples, 0.25 secs
xs = [2;1.5;1]      # Source position
#xr = [1 2   2  ;
#      1 2.3 2.3]'   # Receiver position

Lx,Ly,Lz  = 4.,4.,4.# Room dimensions
xr = LinearGrid([Lx/2,Ly/2,Lz/2],[0.5],3) #3 mic linear array positioned at the center of the room
T60 = 1.0           # Reverberation Time
geo = CuboidRoom(Lx,Ly,Lz,T60)

Tw = 20              # samples of Low pass filter 
Fc = 0.9            # cut-off frequency

# generate IR with new randomization
@time h  = rim(env,Nt,xr,xs,geo)

# generate another IR with same randomization and
@time h2 = rim(env,Nt,xr,xs,geo)

@test norm(h[:]-h2[:]) < 1e-8

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

