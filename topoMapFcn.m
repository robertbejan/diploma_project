function topoMapFcn(data_meg)

% sensorPositions = data_meg.grad.chanpos(1:numel(data_meg.label),:);
% sensorLabels = data_meg.label;
% currentValues = data_meg.trial{1};

sensorPositions = sensorPositions(infoFeatFFT, data_meg);
sensorLabels = data_meg.label;
currentValues = featFFT(1,:);

for i=1:260
    x(1, i) = sensorPositions{i, 2};
    y(1, i) = sensorPositions{i, 3};
end
z = currentValues;

% dX = min(x):(max(x) - min(x)) / 300:max(x);
% dY = min(y):(max(y) - min(y)) / 300:max(y);
% [xq, yq] = meshgrid(dX, dY);

dX = min(x):(max(x) - min(x)) / 260:max(x);
dY = min(y):(max(y) - min(y)) / 260:max(y);
[xq, yq] = meshgrid(dX, dY);

size_trial = size(data_meg.trial{1});

maxim = zeros(1, size_trial(1,2)-1);
med = zeros(1, size_trial(1,2)-1);

s1 = griddata(x, y, z(1, 1:260), xq, yq, 'cubic');
s1(isnan(s1)) = 0;

min_vec = min(s1);
max_vec = max(s1);

for i = 2:size(currentValues, 2)
    s = griddata(x, y, z(:, i), xq, yq, 'cubic'); % in loc de z e fft cu snezorii
    s(isnan(s)) = 0;

    min_vec = [min_vec min(s)];
    max_vec = [max_vec max(s)];

    %aux = abs(s - s1);
    %maxim(i - 1) = max(aux(:));
    %med(i - 1) = mean(aux(:));

    s1 = s;

    if mod(i, 10) == 0
        disp(['Processed ' num2str(i) ' iterations']);
    end

    % Do something with the 's' for each column, for example, save or display
    % figure, imagesc(s);
    % title(['TopoMap for Column ' num2str(i)]);
    % pause(0.1);
end

min_glob = min(min_vec);
max_glob = max(max_vec);

(x-min_glob)/(max_glob-min_glob)*255; % imaginea inainte de scalare


figure;
plot(maxim); title('Maxim');
figure;
plot(med); title('Media');

%% 
sensorPositions1 = sensorPositions(infoFeatFFT, data_meg);
disp(size(sensorPositions1));
sensorLabels = data_meg.label;
currentValues = featFFT(1,:);

for i=1:260
    x(1, i) = sensorPositions1{i, 2};
    y(1, i) = sensorPositions1{i, 3};
end

dX = min(x):(max(x) - min(x)) / 260:max(x);
dY = min(y):(max(y) - min(y)) / 260:max(y);
[xq, yq] = meshgrid(dX, dY);

s1 = griddata(x, y, currentValues(1,1:260), xq, yq, 'cubic');
s1(isnan(s1)) = 0;

min_vec = min(s1);
max_vec = max(s1);

for i = 2:49
    s = griddata(x, y, currentValues(1,i*260+1:i*260+260), xq, yq, 'cubic'); % in loc de z e fft cu snezorii
    s(isnan(s)) = 0;

    min_vec = [min_vec min(s)];
    max_vec = [max_vec max(s)];

    s1 = s;

    if mod(i, 10) == 0
        disp(['Processed ' num2str(i) ' iterations']);
    end

    figure, imagesc(s);
    title(['TopoMap for Column ' num2str(i)]);
    pause(2);
end

% imagesc(s1);
% colorbar;
end


