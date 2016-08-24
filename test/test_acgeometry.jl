#include("../src/acgeometry.jl")
Lx,Ly,Lz = 1.,2.,3.
β,T60 = ones(6), 0.1
myRd,mySr = 1e-7,0
geo = CuboidRoom(Lx,Ly,Lz,T60)
geo = CuboidRoom(Lx,Ly,Lz,β)
geo = CuboidRoom(Lx,Ly,Lz,T60,Rd = myRd, Sr = mySr)
