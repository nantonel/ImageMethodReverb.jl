using ImageMethodReverb, Random, WAV, LinearAlgebra
Fs = 16e3                     # sampling frequency
T60 = 0.9                     # reverberation time

xs = [1, 2, 2]          #src pos (in meters)
xr = [2, 1.5, 1] #mic pos
L = Lx, Ly, Lz =  4.,4.,4.    # room dimensions in meters 
Nt = round(Int,Fs)            #time samples 1 sec

h_se, = rim(xs,xr,L,0.93.*ones(6),Nt,Fs; Rd=0)  # with sweeping echo
h, = rim(xs,xr,L,0.93.*ones(6),Nt,Fs)  # without sweeping echo

wavplay(0.8 .* h_se ./ norm(h,Inf),Fs)
wavplay(0.8 .* h ./ norm(h,Inf),Fs)

using Plots, FFTW
f = rfftfreq(Nt,Fs)
t = range(0; length = Nt, step = 1/Fs )
p1 = plot(t, h_se, xlabel="Time (t)", ylabel="Sound Pressure (Pa)")
plot!(p1, t, h)
p2 = plot(f, 10 .* log10.(abs.(rfft(h_se))), 
          xlabel="Frequency (Hz)", 
          ylabel="Sound Pressure (dB)",
          xlim=[50;500],
         )
plot!(p2, f, 10 .* log10.(abs.(rfft(h))))
plot(p1,p2)
