# testing output of this implementation with the one 
# of Enzo de Sena: http://www.desena.org/sweep/ 
Fs = 4e4            # Sampling frequency
c  = 343    # create new acoustic env with default values
Nt = round(Int64,4E4/4)   # Number of time samples
xs = (2.,1.5,1.)          # Source position
xr = (1.,2.,2.)           # Receiver position
L  = (4.,4.,4.)           # Room dimensions
beta =  0.93.*(ones(6)...,)  # Reflection coefficient
Rd = 0.00          # random displacement   

Tw = 40            # samples of Low pass filter 
Fc = 0.9           # cut-off frequency

# generate IR with randomization
h, = rim(xs,xr,L,beta,Nt,Fs; Tw = Tw, Fc = Fc, Rd = Rd)

hm = readdlm("h.txt")
@test norm(hm-h)<1e-8
