using RIM
using Base.Test
#include("../src/rim.jl")

# testing output of this implementation with the one 
# of Enzo de Sena: http://www.desena.org/sweep/ 


c  = 343.          # Speed of sound
Fs = 4E4           # Sampling frequency
Nt = round(Int64,4E4/4)   # Number of time samples
xs = [2.;1.5;1.]     # Source position
xr = [1.;2.;2.]       # Receiver position
L  = [4.;4.;4.]       # Room dimensions

β =  0.93.*ones(6)  # Reflection coefficient

Tw = 40            # samples of Low pass filter 
Fc = 0.9           # cut-off frequency

Rd = 0.00          # random displacement   

t = linspace(0,Nt*1/Fs,Nt)
# generate IR with randomization
tic()
h, Nr  = rim(Fs,c,xr,xs,L,β,Nt; Rd=Rd, Sr = 0,Tw = Tw)
toc()


using MAT
file = matopen("../MATLAB/h_mat.mat")
hm = read(file, "h_matlab")
close(file)

#using PyPlot
#figure()
#plot(h)
#plot(hm)

@test norm(hm-h)<1e-8

