export revTime
#TODO make this more robust
function revTime(h,env)

	cs = cumsum(flipdim(h.^2,1))
	edc = 10*log10(flipdim(cs./cs[end],1)) #energy decay curve

	rt = zeros(Float64,size(h,2))
	for i = 1:size(h,2)
		ind = findfirst(edc[:,i] .<= -60. )
		if ind == 0 rt[i] = size(h,1)/env.Fs else
			rt[i] = ind/env.Fs
		end
	end

	return rt, edc
end

