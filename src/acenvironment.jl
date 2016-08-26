export AcEnv

immutable AcEnv <: AcousticEnvironment
	Fs::Float64   # sampling frequency
	c::Float64    # speed of sound
	AcEnv(Fs,c) = any([Fs;c].<=0) ? error("Fs,c,ρ must be non negative"): new(Fs,c)
end

AcEnv(Fs) =    AcEnv(Fs,343.)
