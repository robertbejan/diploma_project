function [topoMap] = topoMapFcn(data_meg)

sensorPositions = data_meg.grad.chanpos(1:numel(data_meg.label),:);
sensorLabels = data_meg.label;
currentValues = data_meg.trial{1};

x = sensorPositions(:, 1);
y = sensorPositions(:, 2);

dX = min(x):(max(x) - min(x)) / 300:max(x);
dY = min(y):(max(y) - min(y)) / 300:max(y);
[xq, yq] = meshgrid(dX, dY);

maxim = zeros(1, 2399);
med = zeros(1, 2399);

% s1 = griddata(x, y, z(:, 1), xq, yq, 'cubic');
% s1(isnan(s1)) = 0;

for i = 1:size(currentValues, 2)
    z = currentValues(:, i);
    s = griddata(x, y, z, xq, yq, 'cubic');

    % aux = abs(s - s1);
    % maxim(i - 1) = max(aux(:));
    % med(i - 1) = mean(aux(:));

    % s1 = s;

    if mod(i, 10) == 0
        disp(['Processed ' num2str(i) ' iterations']);
    end

    % Do something with the 's' for each column, for example, save or display
    figure, imagesc(s);
    title(['TopoMap for Column ' num2str(i)]);
    pause(0.1); % Optional pause to see each figure
end
end