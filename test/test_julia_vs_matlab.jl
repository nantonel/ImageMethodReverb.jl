# testing output of this implementation with the one 
# of Enzo de Sena: http://www.desena.org/sweep/ 
Fs = 4e4            # Sampling frequency
env = AcEnv(Fs)   # create new acoustic env with default values
Nt = round(Int64,4E4/4)   # Number of time samples
xs = [2.;1.5;1.]          # Source position
xr = [1.;2.;2.]           # Receiver position
Lx,Ly,Lz  = 4.,4.,4.           # Room dimensions
β =  0.93.*ones(6)  # Reflection coefficient
Rd = 0.00          # random displacement   
geo = CuboidRoom(Lx,Ly,Lz,β; Rd = Rd)

Tw = 40            # samples of Low pass filter 
Fc = 0.9           # cut-off frequency

# generate IR with randomization
@time h  = rim(xs,xr,Nt,geo,env; Tw = Tw, Fc = Fc)

hm = readdlm("h.txt")
@test norm(hm-h)<1e-8
println("matlab reference test passed")
