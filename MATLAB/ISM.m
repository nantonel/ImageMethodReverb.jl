function [h,Sr] =  ISM(xr,xs,L,beta,N,Nt,Rd,Sr,Tw,Fc,Fs,c)

%Image Source Method simulator
%
%Inputs: xr microphone positions (in meters) (3 element array)
%           xr = [xr,yr,zr]
%        xs source position (in meters)
%           xs = [xs,ys,zs]
%	L  room dimension (in meters)
%           L = [Lx,Ly,Lz]
%	β  absorption coefficient 
%	   (6 element array)
%           or T60 if 1 element array 
%	N  order of reflections 
%	   (set to [0,0,0] to compute full order)
%	Nt samples of impulse response
%	Rd random displacement (in meters)
%	Sr seed of the random sequence
%	   (set to [] if you want to compute a new one)
%        Tw samples of fractional delay
%	Fc cutoff frequency of fractional delay
%	Fs Sampling Frequency
%	c  Speed of sound
%Outputs: h  impuse response
%         Sr seed for the randomization
%            set to 0 to generate a new one
%	 (to be used if multiple IR are needed)

	if(length(beta) == 1)  % T60 is in input and is converted to β 
		S = 2*( L(1)*L(2)+L(1)*L(3)+L(2)*L(3) ); % Total surface area
		V = prod(L);
		alpha = -10^(-0.161*V/(beta*S))+1; % Absorption coefficient
		beta =-sqrt(abs(1-alpha)).*ones(6,1); % Reflection coefficient
	end

	L  =  L./c*Fs*2; %#convert dimensions to indices
	xr = xr./c*Fs;
	xs = xs./c*Fs;
	Rd = Rd./c*Fs;

	assert(size(xr,1)==3); %check that the size are correct
	K = size(xr,2);        %number of microphones

	h = zeros(Nt,K);            % initialize output

	
	if(N == [0;0;0])
		N = floor(Nt./L)+1;  % compute full order
	end
    
    
    
	if(isempty(Sr)) %compute new randomization of image sources
	
		Sr = sum(clock.*100);    
		%obtain a new seed from clock
	end
    
  
	for k = 1:K
	
	rand('state', Sr);
        for u = 0:1
        for v = 0:1
        for w = 0:1
			
                for l = -N(1):N(1)
                for m = -N(2):N(2) 
                for n = -N(3):N(3)
	

				%position of image source
				pos_is = [
				xs(1)-2*u*xs(1)+l*L(1);... 
				xs(2)-2*v*xs(2)+m*L(2);...
				xs(3)-2*w*xs(3)+n*L(3)];    
				
				% compute distance
				rand_disp = Rd*(2*rand(3,1)-1)*nnz(sum(abs([u;v;w;l;m;n])));
				d = norm(pos_is+rand_disp-xr(:,k))+1;

				% when norm(sum(abs( [u,v,w,l,m,n])),0) == 0 
				% we have direct path, so
				% no displacement is added
	
				% instead of moving the source on a line
				% as in the paper, we are moving the source 
				% in a cube with 2*Rd edge

                %if index not exceed length h
            
                if(round(d)>Nt || round(d)<1)
                    continue
                end

				if(Tw == 0)
					indx = round(d); %calculate index  
					s = 1;
				else
					indx = (max([ceil(d-Tw/2),1]):min([floor(d+Tw/2),Nt]));
					% create time window
					s = (1+cos(2*pi*(indx-d)/Tw)).*sinc(Fc*(indx-d))/2;
					% compute filtered impulse
				end
	
				A = prod(beta.^abs([l-u;l;m-v;m;n-w;n]))/(4*pi*(d-1));
				h(indx,k) = h(indx,k) + (s.*A)';
			
                end            
                end
                end
                
        end
        end
        end

        end
    
	h = h.*(Fs/c);
