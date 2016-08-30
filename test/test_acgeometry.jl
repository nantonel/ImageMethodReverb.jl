#include("../src/acgeometry.jl")
Lx,Ly,Lz = 1.,2.,3.
β,T60 = ones(6), 0.1
env = AcEnv(4e4)
myRd,mySr = 1e-7,0
geo = CuboidRoom(Lx,Ly,Lz,T60,env)
geo = CuboidRoom(Lx,Ly,Lz,β)
geo = CuboidRoom(Lx,Ly,Lz,T60,env;Rd = myRd, Sr = mySr)
