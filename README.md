# Image method

[![Build status](https://github.com/nantonel/ImageMethodReverb.jl/workflows/CI/badge.svg)](https://github.com/nantonel/ImageMethodReverb.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/nantonel/ImageMethodReverb.jl/coverage.svg?branch=master)](http://codecov.io/github/nantonel/ImageMethodReverb.jl?branch=master)

Acoustic Room Impulse Response (RIR) generator using the (Randomized) Image Method for rectangular rooms.
Useful to add reverberation to audio signals.

## Installation

To install the package, hit `]` from the Julia command line to enter the package manager, then

```julia
pkg> add https://github.com/nantonel/ImageMethodReverb.jl.git
```

## Tutorial

Import the package by typing `using ImageMethodReverb` and specify properties of 
the room of interest:
```julia
using ImageMethodReverb, Random
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

Type `?rim` for more details. By default the randomized image method from [1] is used. The original image method proposed in [2] can be reproduced as well by turining off the randomization and fractional delays.

## Other languages implementations

A MATLAB implementation of the Randomized Image Method can be found [here](https://github.com/enzodesena/rim).

## References

* [1] [E. De Sena, N. Antonello, M. Moonen, and T. van Waterschoot, "On the Modeling of
Rectangular Geometries in Room Acoustic Simulations", IEEE Transactions of Audio, Speech
Language Processing, vol. 21, no. 4, 2015.](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=7045580)
* [2] Allen, Jont B., and David A. Berkley. "Image method for efficiently simulating small‐room acoustics." The Journal of the Acoustical Society of America vol. 65 no. 4, 1979.
