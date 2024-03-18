sensorPositions1 = sensorPositions(infoFeatFFT, data_meg);
% sensorPositions este o functie care determina pozitiile senzorilor chiar
sensorLabels = data_meg.label;
currentValues = featFFT(1,:);

for i = 1:260
    x(1, i) = sensorPositions1{i, 2};
    y(1, i) = sensorPositions1{i, 3};
end

dX = min(x):(max(x) - min(x)) / 260:max(x);
dY = min(y):(max(y) - min(y)) / 260:max(y);
[xq, yq] = meshgrid(dX, dY);

% init min si max
min_val = inf;
max_val = -inf;

% For-loop care caluculeaza min si max global
for i = 1:49
    startIndex = (i - 1) * 260 + 1;
    endIndex = i * 260;
    
    if endIndex > length(currentValues)
        endIndex = length(currentValues);
    end

    % Imaginea pentru iteratia i
    s = griddata(x, y, currentValues(startIndex:endIndex), xq, yq, 'cubic');

    
    % Update la min and max global
    min_val = min(min_val, min(s(:)));
    max_val = max(max_val, max(s(:)));

    if mod(i, 10) == 0
        disp(['Processed ' num2str(i) ' iterations']);
    end
end

% Plotare imagini
for i = 1:49
    startIndex = (i - 1) * 260 + 1;
    endIndex = i * 260;
   
    if endIndex > length(currentValues)
        endIndex = length(currentValues);
    end

    % Imaginea pentru iteratia i
    s = griddata(x, y, currentValues(startIndex:endIndex), xq, yq, 'cubic');

    % Normalizare imagine cu min si max global
    s_normalized = (s - min_val) / (max_val - min_val) * 255;

    s_normalized(isnan(s)) = NaN;

    % Plotare pentru fiecare imagine
    figure;
    imagesc(dX, dY, s_normalized, [0, 255]);
    colorbar;
    pause(2);
end
