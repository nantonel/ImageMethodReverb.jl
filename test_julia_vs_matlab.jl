include("ism.jl")

# testing output of this implementation with the one 
# of Enzo de Sena: 


c  = 343           # Speed of sound
Fs = 4E4           # Sampling frequency
Nt = iround(4E4)   # Number of time samples
xs = [2,1.5,1]     # Source position
xr = [1,2,2]       # Receiver position
L  = [4,4,4]       # Room dimensions
N =  [ 0, 0, 0]    # Reflection order

β =  0.93.*ones(6)  # Reflection coefficient

Tw = 40            # samples of Low pass filter 
Fc = 0.9           # cut-off frequency

Rd = 0.00          # random displacement   

t = linspace(0,Nt*1/Fs,Nt)
# generate IR with randomization
tic()
h, Nr  = ISM(xr,xs,L,  β,N,Nt, 0, 0,Tw,Fc,Fs,c)
toc()


using MAT
file = matopen("h_mat.mat")
hm = read(file, "h_matlab")
close(file)

using PyPlot
figure()
plot(h)
plot(hm)
