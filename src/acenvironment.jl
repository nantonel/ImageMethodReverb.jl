export AcEnv

immutable AcEnv <: AcousticEnvironment
	Fs::Float64   # sampling frequency
	c::Float64    # speed of sound
	ρ::Float64    # air density
	AcEnv(Fs,c,ρ) = any([Fs;c;ρ].<=0) ? error("Fs,c,ρ must be non negative"): new(Fs,c,ρ)
end

AcEnv(Fs,c) =  AcEnv(Fs,c,1.204)
AcEnv(Fs) =    AcEnv(Fs,343.,1.204)
