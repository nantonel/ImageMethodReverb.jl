# RIM


[![Build Status](https://travis-ci.org/nantonel/RIM.jl.svg?branch=master)](https://travis-ci.org/nantonel/RIM.jl.svg?branch=master)


Room Acoustics Impulse Response Generator using the Randomized Image Method (RIM)


## Installation

From the Julia command line hit:

```julia
Pkg.clone("https://github.com/nantonel/RIM.jl.git")
```

Once the package is installed you can update it along with the others issuing `Pkg.update()` in the command line.


## Usage 

Import the package by typing `using RIM`. 
First you need to specify the dimensions of the cuboid room and acoustic properties by typing: 
```julia
using RIM
Lx,Ly,Lz = 4.,5.,3.;
T60 = 0.5;
geo = cuboidRoom(Lx,Ly,Lz,T60);
```
where `Lx`,`Ly`,`Lz` are the room 
dimensions in meters and `T60` 
is the desired reverberation time. 
Alternatively you can specify the reflection 
coefficient \beta using a 6 element Array:
```julia
\beta = [0.9;0.9;0.7;0.7;0.8;0.8];
geo = cuboidRoom(Lx,Ly,Lz,\beta);
```
Once this is done select 
your source position, 
microphone positions,
sampling frequency:
```julia
xs = [0.5 0.5 0.5]';                    #src pos (in meters)
xr = [Lx-0.1 Ly-0.3 Lz-0.2; 2. 2. 2.]'; #mic pos
Fs = 1e4;                               #Sampling Frequency
Nt = round(Int64,Fs);                  #time samples (1 sec)
```
Now type:
```julia
h = rim(Fs,Nt,xr,xs,geo);
```
to obtain your room impulse response.


## Changing default parameters


### `cuboidRoom`


The function `cuboidRoom` has the default additional parameters: 

* `Rd = 1e2`: random displacement of image sources.
* `Sr`: seed of the randomization which by default is a random integer.

One can change this by typing:
```julia
cuboidRoom(Lx,Ly,Lz,T60,Rd = myRd, Sr = mySr)
```
or 
```julia
cuboidRoom(Lx,Ly,Lz,\beta,Rd = myRd, Sr = mySr)
```


### `cuboidRoom`


The function `rim` has the default additional parameters:

* `c = 343.`         : Speed of sound
* `N = [0;0;0]`      : 3 element `Array` representing order of reflection 
                                (set to [0;0;0] to compute full order).
* `Tw = 20`          : taps of fractional delay filter
* `Fc = 0.9`         : cut-off frequency of fractional delay filter

One can change this by typing:
```julia
rim(Fs,Nt,xr,xs,geo; c = myc, N = myN, Tw = myTw, Fc = myFc)
```


## Other languages implementations

A single channel MATLAB implementation of the RIM can be found in:
[http://www.desena.org/sweep/](http://www.desena.org/sweep/)

A less efficient MATLAB multi-channel version can be found here in the MATLAB folder with the same code structure as the Julia version.


## References

1. [E. De Sena, N. Antonello, M. Moonen, and T. van Waterschoot, "On the Modeling of
Rectangular Geometries in Room Acoustic Simulations", IEEE Transactions of Audio, Speech
Language Processing, vol. 21, no. 4, April 2015.](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=7045580)



## Credits

RIM.jl is developed by [Niccolò Antonello](http://homes.esat.kuleuven.be/~nantonel/) at [KU Leuven, ESAT/Stadius](https://www.esat.kuleuven.be/stadius/).
