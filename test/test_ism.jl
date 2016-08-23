#include("../src/rim.jl")
#testing seed

c  = 343.           # Speed of sound
Fs = 4E4            # Sampling frequency
Nt = round(Int64,4E4/4)    # Number of time samples
xs = [2,1.5,1]      # Source position
xr = [1 2   2  ;
      1 2.3 2.3]'   # Receiver position
L  = [4.,4.,4.]     # Room dimensions
T60 = 1.0           # Reverberation Time
β = -0.93.*ones(6)  # Reflection coefficient

Tw = 20              # samples of Low pass filter 
Fc = 0.9            # cut-off frequency

Rd = 0.01           # random displacement   

t = linspace(0,Nt*1/Fs,Nt)
f = linspace(0,Fs,Nt)
# generate IR with new randomization
@time h, Sr  = rim(Fs,c,xr,xs,L,T60,Nt)

# generate another IR with same randomization and
@time h2,    = rim(Fs,c,xr,xs,L,T60,Nt,Sr=Sr)

@test norm(h[:]-h2[:]) < 1e-8

#using PyPlot
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

