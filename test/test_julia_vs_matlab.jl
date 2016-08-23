#include("../src/rim.jl")
#using RIM

# testing output of this implementation with the one 
# of Enzo de Sena: http://www.desena.org/sweep/ 


c  = 343.          # Speed of sound
Fs = 4E4           # Sampling frequency
Nt = round(Int64,4E4/4)   # Number of time samples
xs = [2.;1.5;1.]          # Source position
xr = [1.;2.;2.]           # Receiver position
Lx,Ly,Lz  = 4.,4.,4.           # Room dimensions
β =  0.93.*ones(6)  # Reflection coefficient
Rd = 0.00          # random displacement   
geo = cuboidRoom(Lx,Ly,Lz,β; Rd = Rd)

Tw = 40            # samples of Low pass filter 
Fc = 0.9           # cut-off frequency

# generate IR with randomization
@time h  = rim(Fs,Nt,xr,xs,geo; Tw = Tw, Fc = Fc)

using MAT
file = matopen("../MATLAB/h_mat.mat")
hm = read(file, "h_matlab")
close(file)
@test norm(hm-h)<1e-8

#using PyPlot
#figure()
#plot(h)
#plot(hm)


