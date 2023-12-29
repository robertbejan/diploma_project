function data_meg = trialPreprocessing(data_meg, fq) %valStart)

% close all;

for i=1:numel(data_meg.trial)

    % Filtare pentru frecventa de 240Hz
    fn=60; w0=fn/(fq/2);
    BW=w0/35;
    [bN,aN] = iirnotch(w0, BW);
    data_meg.trial{1,i}=filtfilt(bN,aN,data_meg.trial{1,i});

    % fn=120; w0=fn/(fq/2);
    % BW=w0/35;  %BW=w0/Q;
    % [bN1,aN1] = iirnotch(w0, BW);
    % data_meg.trial{1,i}=filtfilt(bN1,aN1,data_meg.trial{1,i});
    % 
    % fn=180; w0=fn/(fq/2);
    % BW=w0/35;  %BW=w0/Q;
    % [bN2,aN2] = iirnotch(w0, BW);
    % data_meg.trial{1,i}=filtfilt(bN2,aN2,data_meg.trial{1,i});


    % Filtru pentru frecventele joase
    fL=0.5;
    fH=100;
    n=5; %ordinul filtrului
    [bd,ad] = butter(n,[fL, fH]/(fq/2));
    data_meg.trial{1,i}=filtfilt(bd,ad,data_meg.trial{1,i});

    % Fs = data_meg.fsample;            % Sampling frequency
    % T = 1/Fs;                         % Sampling period
    % L = 10000;                      % Length of signal
    % t = (0:L-1)*T;                  % Time vector

    % figure;
    % plot(data_meg.trial{1,i}');

    % Y = fft(data_meg.trial{1,i}');  % X = semnalul dintr-un cadru
    % P2 = abs(Y/L);
    % P1 = P2(1:L/2+1);

    % f = Fs*(0:(L/2))/L;
    % figure;
    % plot(f,P1)
    
    %reconstructie
    % j=1; %electrod
    % Yr=Y(:,j); Yr(valStart+1:end-valStart)=0; 
    % Zr=real(ifft(Yr));  %!!!!  Z=real(ifft(Y(1:K)));
    %compar Zr cu X=data_meg.trial{1,i}(j,:)';
    % 
    % numberOfTimeStamps = size(data_meg.trial{1,1});
    % numberOfTimeStamps = numberOfTimeStamps(1,2);
    % Zr = zeros(numel(data_meg.label), numberOfTimeStamps);

    for k = 1:30
        for j=1:numel(data_meg.label) %electrod
            Y = fft(data.trial{1,k}(j,:)');
            aux = abs(Y(2:valStart));
            Yr=Y(:,j);
            Yr(valStart+1:end-valStart) = 0;
            Yr(valStart+1:end-valStart) = 0;
            Zr(j,:)=real(ifft(Yr))';  %!!!!  Z=real(ifft(Y(1:K)));
        end
        data_meg.trial{1,k} = Zr;
    end

    % %compar Zr cu X=data_meg.trial{1,i}(j,:)';
    % featFFT = real(Yr(2:valStart,:));
    % featFFT = featFFT(:)';
    
    % featFFT = Y (2:valStart,:);
    % featFFT = featFFT(:)';
    
    % plot(Z)
    % -> abs(Y(1:k))

end
    fprintf('Data has been preprocessed \n-');
end