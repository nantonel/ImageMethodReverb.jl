using RIM
using Base.Test

X = 0.4
lx,ly,lz = 1.,1.,1.
xc = [lx/2;ly/2;lz/2]

LG = LinearGrid(xc,lx,ly,lz,X) #cubic array
LG2 = LinearGrid(xc,lx,ly,X)    #square array
LG3 = LinearGrid(xc,lx,X)      #line array

#using PyPlot
#figure()
#plot(LG2.pos[1,:]',LG2.pos[2,:]', "r*")
#plot(LG3.pos[1,:]',LG3.pos[2,:]', "*")

Nx,Ny,Nz = 6,6,6
LG = LinearGrid(xc,[lx;ly;lz],Nx,Ny,Nz) #cubic array
@test size(LG.pos,2) == Nx^3
LG2 = LinearGrid(xc,[lx;ly],Nx) #cubic array
@test size(LG2.pos,2) == Nx^2
LG3 = LinearGrid(xc,[lx],Nx) #cubic array
@test size(LG3.pos,2) == Nx

#using PyPlot
#figure()
#plot(LG2.pos[1,:]',LG2.pos[2,:]', "r*")
#plot(LG3.pos[1,:]',LG3.pos[2,:]', "*")
