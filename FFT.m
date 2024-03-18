Fs = data_meg.fsample;            % Sampling frequency
T = 1/Fs;                         % Sampling period
L = 10000;                      % Length of signal
t = (0:L-1)*T;                  % Time vector

figure;
plot(data_meg.trial{1,i}');

Y = fft(data_meg.trial{1,i}');  % X = semnalul dintr-un cadru
P2 = abs(Y/L);
P1 = P2(1:L/2+1);

f = Fs*(0:(L/2))/L;
figure;
plot(f,P1)

% reconstructie
j=1; %electrod
Yr=Y(:,j); 
plot(Yr); Yr(valStart+1:end-valStart)=0;
Zr=real(ifft(Yr));  %!!!!  Z=real(ifft(Y(1:K)));
% compar Zr cu 
X=data_meg.trial{1,i}(j,:)';
plot(X);

numberOfTimeStamps = size(data_meg.trial{1,1});
numberOfTimeStamps = numberOfTimeStamps(1,2);
Zr = zeros(numel(data_meg.label), numberOfTimeStamps);