# RIM


[![Build Status](https://travis-ci.org/nantonel/RIM.jl.svg?branch=master)](https://travis-ci.org/nantonel/RIM.jl.svg?branch=master)


Room Acoustics Impulse Response Generator using the Randomized Image Method (RIM)


## Installation

From the Julia command line hit:

```
Pkg.clone("https://github.com/nantonel/RIM.jl.git")
```

Once the package is installed you can update it along with the others issuing `Pkg.update()` in the command line.


## Usage 

Import the package by typing `using RIM`. You can generate the impulse respones of a cuboid room by typing: 
```julia
h = = rim(Fs,c,xr,xs,L,T60,Nt)
```

### Arguments: 

* `Fs::Float64`         : Sampling Frequency 
* `c::Float64`          : Speed of sound
* `xr::Array{Float64}`  : Microphone positions (in meters) (3 by `Nm` Array) where `Nm` is number of microphones
* `xs::Array{Float64}`  : source positions (in meters) (must be a 3 by 1 Array)
* `L::Array{Float64,1}` : room dimensions  (in meters), must be a 3 dimensional Array
* `β`                   : if a 6 element Array is given each element 
                          represents the reflectlion coefficient of a wall, 
                          if a 1 element Array is given instead this represents 
                          the `T60` and all the walls have the same reflection coefficients 
                          Nt samples of impulse response


### Optional parameters:

* `N:Array{Int64,1} = [0;0;0]`: 3 element Array representing order of reflection 
                                (set to `[0;0;0]` to compute full order).
* `Rd::Float64 = 1e-2`        : random displacement of image sources (in meters).
* `Sr = []`                   : seed of the random sequence (set to `[]` if you want to compute a new randomization). 
* `Tw::Int64 = 20`            : taps of fractional delay filter
* `Fc::Float64 = 0.9`         : cut-off frequency of fractional delay filter


### Outputs: 
* `h::Array{Float64}`: `h` is a matrix where each column 
		       corresponts to the impulse response of 
		       the microphone positions `xr`
* `Sr::Int32`        : seed for the randomization (to be saved if a different RIM simulation is run with the same randomization. 



## Other languages implementations

A single channel MATLAB implementation of the RIM can be found in:
[http://www.desena.org/sweep/](http://www.desena.org/sweep/)

A less efficient MATLAB multi-channel version can be found here in the MATLAB folder with the same code structure as the Julia version.


## References

1. [E. De Sena, N. Antonello, M. Moonen, and T. van Waterschoot, "On the Modeling of
Rectangular Geometries in Room Acoustic Simulations", IEEE Transactions of Audio, Speech
Language Processing, vol. 21, no. 4, April 2015.](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=7045580)


Notice that instead of moving the source on a line as in the paper, here the image sources are dispalced in a cube with (2 Rd) edge.


## Credits

RIM.jl is developed by [Niccolò Antonello](http://homes.esat.kuleuven.be/~nantonel/) at [KU Leuven, ESAT/Stadius](https://www.esat.kuleuven.be/stadius/).
