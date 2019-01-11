# RIM

[![Build Status](https://travis-ci.org/nantonel/RIM.jl.svg?branch=master)](https://travis-ci.org/nantonel/RIM.jl.svg?branch=master)
[![Build status](https://ci.appveyor.com/api/projects/status/j52r0fu5cl0ip0ed?svg=true)](https://ci.appveyor.com/project/nantonel/rim-jl)
[![Coverage Status](https://coveralls.io/repos/github/nantonel/RIM.jl/badge.svg?branch=master)](https://coveralls.io/github/nantonel/RIM.jl?branch=master)

Acoustic Room Impulse Response (RIR) generator using the Randomized Image Method (RIM) for rectangular geometries.

## Installation

To install the package, hit `]` from the Julia command line to enter the package manager, then

```julia
pkg> add https://github.com/nantonel/RIM.jl.git
```

## Usage 

Import the package by typing `using RIM` and specify properties of 
the room of interest:
```julia
using RIM, Random
Fs = 8e3          # sampling frequency
L = 4.,5.,3.      # room dimensions in meters 
T60 = 0.7         # reverberation time
```
If the reverberation time is given, all the walls will 
have the same reflection coefficient.
Alternatively it is possible to manually change this  
using a six element `Tuple`:
```julia
β = (0.9,0.9,0.7,0.7,0.8,0.8) 
#(  βx1     ,    βx2   ,    βy1   ,    βy2    ,  βz1 ,   βz2  )
#(front wall, rear wall, left wall, right wall, floor, ceiling)
```

Once the properties of the room are given, 
select your source and 
microphone position:
```julia
xs = (0.5, 0.5, 0.5)          #src pos (in meters)
xr = (Lx-0.1, Ly-0.3, Lz-0.2) #mic pos
Nt = round(Int,Fs/2)          #time samples (1/5 sec)
```
Now type:
```julia
h, = rim(xs,xr,L,T60,Nt,Fs)
```
to obtain your room impulse response.

You can also use multiple microphone position by providing 
an array of `Tuple`s containing the microphone coordinates.
```julia
h, = rim(xs,[(1,1,1),(1,1.5,1)],L,T60,Nt,Fs)
```
Here `h` will consist of a matrix: `h[:,1]` will be the RIR 
relative to the microphone in `(1,1,1)` etc. 
It is also possible to specify the source signal 
to directly obtain the sound pressure at the microphones:
```julia
s = randn(Nt)   #src signal 
```
and type:
```julia
p, = rim(s,xs,[(1,1,1),(1,1.5,1)],L,T60,Nt,Fs)
```

## Method signature

`h, seed = rim([s,] xs, xr, L, T60, Nt, Fs)`

Randomized Image Source Method

#### Arguments: 

* `s`   : (Optional) Source signals
* `xs`  : Source position in meters (must be a Tuple)
* `xr`  : Microphone position in meters (must be a `Tuple` or a `Vector{Tuple}` for mic array)
* `Nt`  : Time samples
* `L`   : 3 element `Tuple` containing dimensions of the room 
* `beta`/`T60` : 6 element `Tuple` containing reflection coefficients of walls/reverberation time
* `Nt`  : length of the RIR
* `Fs`  : sampling frequency

#### Keyword Arguments:

* `c = 343`    : speed of sound 
* `Rd = 1e-2`  : random displacement (in meters)
* `N = (0,0,0)`: 3 element `Tuple` representing order of reflection when `N == (0;0;0)` full order is computed.
* `Tw = 20`    : taps of fractional delay filter
* `Fc = 0.9`   : cut-off frequency of fractional delay filter


#### Outputs: 
* `h`: vector or matrix where each column is an impulse response or the sound pressure if `s` was specified corresponding to the microphone positions `xr`
* `seed`: randomization seed to preserve spatial properties when other RIR at different position are needed


## Other languages implementations

A single channel MATLAB implementation of the RIM can be found in:
[http://www.desena.org/sweep/](http://www.desena.org/sweep/)

A multi-channel MATLAB version can be found in this repository in the [src/MATLAB folder](https://github.com/nantonel/RIM.jl/tree/master/src/MATLAB). Notice that the Julia version outperforms both implementations in terms of speed.

## References

1. [E. De Sena, N. Antonello, M. Moonen, and T. van Waterschoot, "On the Modeling of
Rectangular Geometries in Room Acoustic Simulations", IEEE Transactions of Audio, Speech
Language Processing, vol. 21, no. 4, April 2015.](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=7045580)


## Credits

RIM.jl is developed by [Niccolò Antonello](http://homes.esat.kuleuven.be/~nantonel/) at [KU Leuven, ESAT/Stadius](https://www.esat.kuleuven.be/stadius/).
