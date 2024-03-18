% Generare imagini
tic
sizeOfFeatFFT = 600;
valStart = 50;

[featFFT, infoFeatFFT, target_class_training, sensorPositions] = trainingMatrixTopo(sizeOfFeatFFT,valStart);

% Imaginea pentru iteratia I – as putea sa fac fft direct aici

currentDateTime = datestr(now, 'yyyy-mm-dd_HH-MM');
folderName = ['Workspace_Topo_', currentDateTime, '_', num2str(sizeOfFeatFFT)];
directoryPath = 'F:\Training Saves';

for i=1:sizeOfFeatFFT
    disp('for iteration: ')
    disp(num2str(i));
    images = [];
    numOfSensors = numel(infoFeatFFT(i).sensors);
    currentValues = featFFT{i};
    x = []; y = [];
    for j = 1:numOfSensors
        x(1, j) = sensorPositions{1, i}{j,2};
        y(1, j) = sensorPositions{1, i}{j,3};
    end
    dX = min(x):(max(x) - min(x)) / 300:max(x);
    dY = min(y):(max(y) - min(y)) / 300:max(y);
    [xq, yq] = meshgrid(dX, dY);
    sizexq = size(xq); sizeyq = size(yq);
    if sizexq(1) == 301 && sizeyq(1) == 301
        for p = 1:valStart-1
            %startIndex = (k - 1) * numOfSensors + 1;
            % endIndex = k * numOfSensors;
            aux = griddata(x, y, currentValues(p:(valStart-1):end), xq, yq, 'nearest');
            vec=isnan(aux);
            aux(vec)=0;
            vec=(aux<0);
            aux(vec)=0;
            images(:,:,p)=aux;
        end

        % salvare
        cd(directoryPath);

        % Create the directory if it doesn't exist
        if ~exist(folderName, 'dir')
            mkdir(folderName);
        end

        cd(folderName);

        % Create subdirectory for data
        dataFolder = 'data';
        if ~exist(dataFolder, 'dir')
            mkdir(dataFolder);
        end

        cd(dataFolder);
        varName = ['image', num2str(i)]; % Construct unique variable name
        save([varName, '.mat'], 'images'); % Save each image in a separate MAT fill
    end
    save('infoFeatFFT', 'infoFeatFFT');
    save('target_class_training', 'target_class_training');
end

toc

% figure;
% imagesc(x, y, images{1, 1}(:,:,42), [0, 255]);
% colorbar;
% pause(2);

% salvare
% directoryPath = 'F:\Training Saves';
% cd(directoryPath);
% currentDateTime = datestr(now, 'yyyy-mm-dd_HH-MM');
% folderName = ['Workspace_Topo_', currentDateTime, '_', num2str(sizeOfFeatFFT)];
%
% % Create the directory if it doesn't exist
% if ~exist(folderName, 'dir')
%     mkdir(folderName);
% end
%
% cd(folderName);
% save('infoFeatFFT', 'infoFeatFFT');
% save('target_class_training', 'target_class_training');
%
% % Create subdirectory for data
% dataFolder = 'data';
% if ~exist(dataFolder, 'dir')
%     mkdir(dataFolder);
% end
%
% cd(dataFolder);
% image = {};
%
% for i = 1:numel(images) % Iterate over each image
%     image = images{i};
%     varName = ['image', num2str(i)]; % Construct unique variable name
%     save([varName, '.mat'], 'image'); % Save each image in a separate MAT file
% end

