"""
DEMO: Generating RIRs for a microphone pair, for multiple source positions.
-----

- The source positions are selected on concentric circular grids around the array center. The grid can be uniformly spaced, or randomized.
- The RIRs and other metatata are exported as .npz file (which can then be loaded in Python scripts using numpy.load - an example is shown)


Author
------
Maja Taseska
FWO Postdoctoral Fellow, KU Leuven ESAT-STADIUS
"""


using ImageMethodReverb, Random, Plots, LinearAlgebra, NPZ
Fs = 16000                          # sampling frequency

#-------------------------
# Room parameters
#-----------------
L = Lx, Ly, Lz = 7.,8.,3.                   # room dimensions in meters
micdist = 0.15;                             # microphone distance
T60 = 0.4                                   # reverberation time in seconds
Nt = round(Int,T60*Fs);                     # RIR length

#-------------------------
# Sources
#-------------------------
d_grid = [1.5, 2, 2.5, 3];      # distance grid
theta_grid = collect(0:10:355)*pi/180;      # angle grid
ee_grid = hcat(cos.(theta_grid),sin.(theta_grid))';

# Store the randomized grid in advance
preliminary_dist = zeros(length(d_grid),length(theta_grid));
preliminary_angle = zeros(length(d_grid),length(theta_grid));
for dd = 1:length(d_grid)
    for th = 1:length(theta_grid)
        # OFF GRID FOR TESTING
        ddt = d_grid[dd] + (rand().- 0.5)*0.4
        tht = rand()*2*pi
        preliminary_dist[dd,th] = ddt
        preliminary_angle[dd,th] = tht
    end
end

#-------------------------
# Microphones
#-------------------------
C = [2.5; 2.3; 1.6];                        # array center
rec1 = C - [micdist/2, 0, 0];
rec2 = C + [micdist/2, 0, 0];
currentreceivers = [tuple(rec1...),tuple(rec2...)];


#--------------------------------
# MAIN PART: GENERATING THE RIRS
#-------------------------------

# Initialize arrays to store the different variables
sources_regulargrid = [];
distances_regulargrid = [];
rirs_regulargrid = [];

sources_randgrid = [];
distances_randgrid = [];
rirs_randgrid = [];


for dd = 1:length(d_grid)               #---- Loop over the distance grid
    for th = 1:length(theta_grid)       # ---- Loop over the source angles

        # source positions on a regular grid
        tmpsourcepos = vcat(d_grid[dd]*ee_grid[:,th] + C[1:2], C[3])
        if (0.3 < tmpsourcepos[1] < Lx-0.3 && 0.3< tmpsourcepos[2] < Ly-0.3 )  # check that minimum 30 cm from walls
            tmprir, = rim(tuple(tmpsourcepos...),currentreceivers,L,T60,Nt,Fs)
            if sources_regulargrid == []
                sources_regulargrid = tmpsourcepos
                distances_regulargrid = d_grid[dd]
                rirs_regulargrid = tmprir
            else
                sources_regulargrid = hcat(sources_regulargrid,tmpsourcepos)
                distances_regulargrid = vcat(distances_regulargrid,d_grid[dd])
                rirs_regulargrid = cat(dims = 3,rirs_regulargrid,tmprir)
            end

        end

        # source positions on a randomized grid
        ddt = preliminary_dist[dd,th]
        tht = preliminary_angle[dd,th]
        eet = hcat(cos.(tht),sin.(tht))';
        tmpt = vcat(ddt*eet + C[1:2], C[3])
        #
        if (0.3 < tmpt[1] < Lx-0.3 && 0.3< tmpt[2] < Ly-0.3 )     # check that minimum 30 cm from walls
            tmprir, = rim(tuple(tmpt...),currentreceivers,L,T60,Nt,Fs)
            if sources_randgrid == []
                sources_randgrid = tmpt
                distances_randgrid = ddt
                rirs_randgrid = tmprir
            else
                sources_randgrid = hcat(sources_randgrid,tmpt)
                distances_randgrid = vcat(distances_randgrid,ddt)
                rirs_randgrid = cat(dims = 3,rirs_randgrid,tmprir)
            end
        end
    end
end


#------------------
# Saving the data
#------------------
mydict = Dict("rirs_regulargrid"=>rirs_regulargrid,
              "rirs_randgrid"=>rirs_randgrid,
              "sources_regulargrid"=>sources_regulargrid,
              "sources_randgrid"=>sources_randgrid,
              "distances_regulargrid"=>distances_regulargrid,
              "distances_randgrid"=>distances_randgrid,
              "T60"=>[T60],
              "roomdim" => collect(L),
              "fs"=>[Fs],
              "micdist"=>micdist,
              "arrcenter"=> C);


npzwrite("saved_data.npz", mydict)



#---------------------------------------------
# Uncomment the two lines below to plot the source positions
#--------------------------------------------

#scatter!(sources_regulargrid[1,:],sources_regulargrid[2,:])
#scatter!(sources_randgrid[1,:],sources_randgrid[2,:])

#---------------------------------------------
#---------------------------------------------
#---------------------------------------------
# !!! ONLY TO BE USED IN PYTHON SCRIPTS
#---------------------------------------------
# The code excerpt below shows how to load the saved data in a python script.
# Create a python file, e.g., "check_positions.py", copy the code below, and run the file.
# Make sure that the imported packages (numpy and matplotlib.pyplot) are installed in your environment.
#---------------------------------------------
"""
import numpy as np
from matplotlib import pyplot as plt


data = np.load('saved_data.npz')

# To check what has been stored uncomment:
#data.files

s1 = data['sources_randgrid'].T
s2 = data['sources_regulargrid'].T
rir1 = data['rirs_randgrid']
rir2 = data['rirs_regulargrid']
arrcenter = data['arrcenter']
micx = [arrcenter[0]-data['micdist']/2,arrcenter[0]+data['micdist']/2]
micy = [arrcenter[1], arrcenter[1]]


plt.figure()
plt.scatter(s1[:,0],s1[:,1])
plt.scatter(s2[:,0],s2[:,1], color = 'r')
plt.scatter(micx,micy, color = 'k')

"""
