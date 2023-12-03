function topoMapFcn(data_meg)

sensorPositions = data_meg.grad.chanpos(1:numel(data_meg.label),:);
sensorLabels = data_meg.label;
currentValues = data_meg.trial{1};

x = sensorPositions(:, 1);
y = sensorPositions(:, 2);
z = currentValues;

dX = min(x):(max(x) - min(x)) / 300:max(x);
dY = min(y):(max(y) - min(y)) / 300:max(y);
[xq, yq] = meshgrid(dX, dY);

size_trial = size(data_meg.trial{1});

maxim = zeros(1, size_trial(1,2)-1);
med = zeros(1, size_trial(1,2)-1);

s1 = griddata(x, y, z(:, 1), xq, yq, 'cubic');
s1(isnan(s1)) = 0;

for i = 2:size(currentValues, 2)
    s = griddata(x, y, z(:, i), xq, yq, 'cubic');
    s(isnan(s)) = 0;

    aux = abs(s - s1);
    maxim(i - 1) = max(aux(:));
    med(i - 1) = mean(aux(:));

    s1 = s;

    if mod(i, 10) == 0
        disp(['Processed ' num2str(i) ' iterations']);
    end

    % Do something with the 's' for each column, for example, save or display
    % figure, imagesc(s);
    % title(['TopoMap for Column ' num2str(i)]);
    % pause(0.1);
end
figure;
plot(maxim); title('Maxim');
figure;
plot(med); title('Media');
end