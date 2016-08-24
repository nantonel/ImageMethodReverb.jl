using RIM
#testing frequency dependent boundaries

c  = 343.           # Speed of sound
Fs = 8E3            # Sampling frequency
Nt = round(Int64,4E4/8)    # Number of time samples, 0.25 secs
xs = [2.;1.5;1.]      # Source position
xr = [1. 2.  2.]'   # Receiver position
Lx,Ly,Lz  = 7.,6.,8.# Room dimensions

srand(7)
b = [0.64;  -0.78;   0.14] 
a = [ 1.0;  -1.43;   0.44]

geo = CuboidRoomFD(Lx,Ly,Lz,b,a,500; Rd = 0.)
geo2 = CuboidRoom(Lx,Ly,Lz,0.9*ones(6); Rd = 0.)

## generate IR with frequency dependent β
@time h  = rim(Fs,Nt,xr,xs,geo; N = [4;4;4])
#
## generate another IR with frequency independent β
@time h2 = rim(Fs,Nt,xr,xs,geo2; N = [4;4;4])

#using PyPlot
#t = linspace(0,Nt*1/Fs,Nt)
#f = linspace(0,Fs,Nt)
#figure()
#subplot(2,1,1)
#plot(t,h)
#plot(t,h2)
#subplot(2,1,2)
#plot(f,10.*log10(abs(fft(h))))
#xlim([0,500])
#plot(f,10.*log10(abs(fft(h2))))
#xlim([0,4e3])
#by inspection of the figure it can be seen that the
#deleys are correct.
#βir must be chose carefully since can lead to instability