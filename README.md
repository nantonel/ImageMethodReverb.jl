# RIM


[![Build Status](https://travis-ci.org/nantonel/RIM.jl.svg?branch=master)](https://travis-ci.org/nantonel/RIM.jl.svg?branch=master)
[![Build status](https://ci.appveyor.com/api/projects/status/j52r0fu5cl0ip0ed?svg=true)](https://ci.appveyor.com/project/nantonel/rim-jl)
[![Coverage Status](https://coveralls.io/repos/github/nantonel/RIM.jl/badge.svg?branch=master)](https://coveralls.io/github/nantonel/RIM.jl?branch=master)

Room Acoustics Impulse Response Generator using the Randomized Image Method (RIM)


## Installation

From the Julia command line hit:

```julia
Pkg.clone("https://github.com/nantonel/RIM.jl.git")
```

Once the package is installed you can update it along with the others issuing `Pkg.update()` in the command line.


## Usage 

Import the package by typing `using RIM`. 
First you need to specify an acoustic environment 
and sampling frequency: 
```julia
using RIM
Fs = 8e3          # sampling frequency
env = AcEnv(Fs)   # create new acoustic env with default values
```
by default the speed of sound is chosen to be 343 m/s.
You can change this using `AcEnv(Fs,c)`
where `c` is the speed of sound you want.
Create the geometry of the room  by typing: 
```julia
Lx,Ly,Lz = 4.,5.,3.;
T60 = 0.7;
geo = CuboidRoom(Lx,Ly,Lz,T60);
```
where `Lx`,`Ly`,`Lz` are the room 
dimensions in meters and `T60` 
is the desired reverberation time. 
If you do so, all the walls will 
have the same reflection coefficient β.
Alternatively you can specify the reflection 
coefficient β for each wall using a 6 element Array:
```julia
β = [0.9;0.9;0.7;0.7;0.8;0.8]; #[   βx1    ;    βx2   ;    βy1   ;    βy2    ;  βz1 ;   βz2  ]
                               #[front wall; rear wall; left wall; right wall; floor; ceiling]
geo = CuboidRoom(Lx,Ly,Lz,β);
```
You can also use frequency 
dependent reflection coefficients 
by specifying an IIR filter.
```julia
b = [0.64;  -0.78;   0.14] 
a = [ 1.0;  -1.43;   0.44]
NT = 100;                       #number of samples for which the convolution with IIR is truncated
geo = CuboidRoomFD(Lx,Ly,Lz,b,a,NT);
```
Notice that frequency dependent 
reflection coefficients 
leads to simulations that are 
more computationally expensive.

Once this is done select 
your source position, 
microphone positions and
sampling frequency:
```julia
xs = [0.5 0.5 0.5]';                    #src pos (in meters)
xr = [Lx-0.1 Ly-0.3 Lz-0.2; 2. 2. 2.]'; #mic pos
Nt = round(Int64,Fs/2);                 #time samples (1/5 sec)
```
Now type:
```julia
h = rim(env,Nt,xr,xs,geo);
```
to obtain your room impulse response.


## Changing default parameters with Keyword Arguments


### `CuboidRoom`


The function `CuboidRoom` has the default additional parameters: 

* `Rd = 1e2`: random displacement of image sources.
* `Sr`: seed of the randomization which by default is a random integer.

One can change this by typing:
```julia
CuboidRoom(Lx,Ly,Lz,T60,Rd = myRd, Sr = mySr)
```
or 
```julia
CuboidRoom(Lx,Ly,Lz,β,Rd = myRd, Sr = mySr)
```

### `CuboidRoomFD`


The function `CuboidRoomFD` has the same default additional parameters as `CuboidRoom`. 


### `rim`


The function `rim` has the default additional parameters:

* `N = [0;0;0]`      : 3 element `Array` representing order of reflection 
                                (set to [0;0;0] to compute full order).
* `Tw = 20`          : taps of fractional delay filter
* `Fc = 0.9`         : cut-off frequency of fractional delay filter

One can change this by typing:
```julia
rim(env,Nt,xr,xs,geo; N = myN, Tw = myTw, Fc = myFc)
```


## Other languages implementations

A single channel MATLAB implementation of the RIM can be found in:
[http://www.desena.org/sweep/](http://www.desena.org/sweep/)

A less efficient MATLAB multi-channel version can be found here in the MATLAB folder with the similar code structure as in the Julia version.


## References

1. [E. De Sena, N. Antonello, M. Moonen, and T. van Waterschoot, "On the Modeling of
Rectangular Geometries in Room Acoustic Simulations", IEEE Transactions of Audio, Speech
Language Processing, vol. 21, no. 4, April 2015.](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=7045580)



## Credits

RIM.jl is developed by [Niccolò Antonello](http://homes.esat.kuleuven.be/~nantonel/) at [KU Leuven, ESAT/Stadius](https://www.esat.kuleuven.be/stadius/).
