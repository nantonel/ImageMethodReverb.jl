using ImageMethodReverb, Random
Fs = 8e3                        # sampling frequency
L = Lx, Ly, Lz =  4.,5.,3.      # room dimensions in meters 
T60 = 0.7                       # reverberation time
# or alternatively 
#β = (0.9,0.9,0.7,0.7,0.8,0.8) 
#(  βx1     ,    βx2   ,    βy1   ,    βy2    ,  βz1 ,   βz2  )
#(front wall, rear wall, left wall, right wall, floor, ceiling)

xs = (0.5, 0.5, 0.5)          #src pos (in meters)
xr = (Lx-0.1, Ly-0.3, Lz-0.2) #mic pos
Nt = round(Int,Fs/2)          #time samples (1/5 sec)

#h, = rim(xs,xr,L,β,Nt,Fs)
h, = rim(xs,xr,L,T60,Nt,Fs)
t = range(0; length = Nt, step = 1/Fs )

# more mics
h, = rim(xs,[(1,1,1),(1,2,1)],L,T60,Nt,Fs)

#with source signal
s = randn(Nt)   #src signal 
p, = rim(s,xs,[(1,1,1),(1,1.5,1)],L,T60,Nt,Fs)

using Plots
p = plot(t,h, xlabel="Time", ylabel="Sound Pressure")
