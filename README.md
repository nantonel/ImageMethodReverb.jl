# Image Method Reverb

[![DOI](https://zenodo.org/badge/31613348.svg)](https://zenodo.org/badge/latestdoi/31613348)
[![Build status](https://github.com/nantonel/ImageMethodReverb.jl/workflows/CI/badge.svg)](https://github.com/nantonel/ImageMethodReverb.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/nantonel/ImageMethodReverb.jl/coverage.svg?branch=master)](http://codecov.io/github/nantonel/ImageMethodReverb.jl?branch=master)

Acoustic Room Impulse Response (RIR) generator using the (Randomized) Image Method for rectangular rooms. Convolving a RIR with an audio file adds reverberation.

## Installation

To install the package, hit `]` from the Julia command line to enter the package manager, then

```julia
pkg> add ImageMethodReverb
```

See the demo folder for some examples.

Type `?rim` for more details. By default the randomized image method from [1] is used. The original image method proposed in [2] can be reproduced as well by turning off the randomization and fractional delays.

## Other languages implementations

A MATLAB implementation of the Randomized Image Method can be found [here](https://github.com/enzodesena/rim).

## References

* [1] [E. De Sena, N. Antonello, M. Moonen, and T. van Waterschoot, "On the Modeling of
Rectangular Geometries in Room Acoustic Simulations", IEEE Transactions of Audio, Speech
Language Processing, vol. 21, no. 4, 2015.](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=7045580)
* [2] Allen, Jont B., and David A. Berkley. "Image method for efficiently simulating small‐room acoustics." The Journal of the Acoustical Society of America vol. 65 no. 4, 1979.
