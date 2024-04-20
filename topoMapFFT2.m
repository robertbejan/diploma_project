addpath D:\Facultate\Licenta\licenta_git\diploma_project

% Generare imagini
tic
sizeOfFeatFFT = 1000;
valStart = 50;

cd('F:\Training Saves\Workspace_2024-01-13_17-18_1000')
load("workspace_variables.mat");
infoRandomForest = infoFeatTest;
list = cell(1,numel(infoFeatTest));
for i=1:numel(infoFeatTest)
    disp(i);
    lista{i} = infoFeatTest(i).subject;
    lista{i} = strrep(lista{i},'sub_','SUB-');
end

[featFFT, infoFeatFFT, target_class_training, sensorPositions] = trainingMatrixTopo(sizeOfFeatFFT,valStart,lista);

% Imaginea pentru iteratia I – as putea sa fac fft direct aici

currentDateTime = datestr(now, 'yyyy-mm-dd_HH-MM');
folderName = ['Workspace_Topo_', currentDateTime, '_', num2str(sizeOfFeatFFT)];
directoryPath = 'F:\Training Saves';
cd(directoryPath);
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

cd(folderName);
save('featFFT', 'featFFT');

save('infoFeatFFT', 'infoFeatFFT');
save('target_class_training', 'target_class_training');
save('sensorPositions', 'sensorPositions');

sizeOfFeatFFT = numel(featFFT);

i=0;
while i<=sizeOfFeatFFT
    i = i + 1;
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
            % startIndex = (k - 1) * numOfSensors + 1;
            % endIndex = k * numOfSensors;
            aux = griddata(x, y, currentValues(p:(valStart-1):end), xq, yq, 'nearest');
            % aux2 = griddata(x, y, currentValues(p:(valStart-1):end), xq, yq, 'natural');
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
    else
        infoFeatFFT(i) = [];
        target_class_training(i) = [];
        sensorPositions(i) = [];
        featFFT(i) = [];
        i = i-1;
        sizeOfFeatFFT = sizeOfFeatFFT - 1;
        disp('error found');
    end
end

cd(directoryPath);
cd(folderName);
save('featFFTnew', 'featFFT');
save('infoFeatFFT', 'infoFeatFFT');
save('target_class_training', 'target_class_training');
save('sensorPositions', 'sensorPositions');

toc

% cnnMain.m