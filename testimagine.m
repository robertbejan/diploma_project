load date_meg.mat

x = sensorPositions(:, 1);
y = sensorPositions(:, 2);
z = currentValues(28:273 + 27, :);

dX = min(x):(max(x) - min(x)) / 700:max(x);
dY = min(y):(max(y) - min(y)) / 700:max(y);
[xq, yq] = meshgrid(dX, dY);

maxim = zeros(1, 23999);
med = zeros(1, 23999);

[xq, yq] = meshgrid(dX, dY);
s1 = griddata(x, y, z(:, 1), xq, yq, 'cubic');
s1(isnan(s1)) = 0;

for i = 2:24000
    s = griddata(x, y, z(:, i), xq, yq, 'cubic');
    s(isnan(s)) = 0;
    
    aux = abs(s - s1);
    maxim(i - 1) = max(aux(:));
    med(i - 1) = mean(aux(:));
    
    s1 = s; 
    
    if mod(i, 10) == 0
        disp(['Processed ' num2str(i) ' iterations']);
    end
end

figure, imagesc(s)



