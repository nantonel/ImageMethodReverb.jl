clear all;
c  = 343;           % Speed of sound
Fs = 4E4;           % Sampling frequency
Nt = round(4E4/4);    % Number of time samples
xs = [2,1.5,1];     %  Source position
xr = [1 2   2  ; ...
      1 2.3 2.3]';   % Receiver position
L  = [4;4;4];        % Room dimensions
N =  [ 0;0;0];       % Reflection order
T60 = 1.0;            % Reverberation Time
beta = -0.93.*ones(6,1);% Reflection coefficient

Tw = 20;            % samples of Low pass filter 
Fc = 0.9;           % cut-off frequency

Rd = 0.08;          % random displacement   

t = linspace(0,Nt*1/Fs,Nt);
f = linspace(0,Fs,Nt);
% generate IR with new randomization
tic()
[h, Sr]  = ISM(xr,xs,L,T60,N,Nt, Rd, 0,Tw,Fc,Fs,c);
toc()
% generate another IR with no randomization

tic()
[h2,~]   = ISM(xr,xs,L,T60,N,Nt,0,0,Tw,Fc,Fs,c);
toc()

figure()
plot(t,h)
hold all;
plot(t,h2)

figure()
plot(f,10.*log10(abs(fft(h))))
hold all;
plot(f,10.*log10(abs(fft(h2))))
xlim([0,500])
