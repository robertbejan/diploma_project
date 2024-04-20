clear all
close all
clc
pathData='F:\Training Saves\log_test\data';
pathMain='F:\Training Saves\log_test';
addpath D:\Facultate\Licenta\licenta_git\diploma_project
cd(pathMain)
load("target_class_training.mat");

%% Parametri
% arhitectura

numFilters = [16 32 32];
numHiddenUnits = [64 32];
numClasses = 2;
numSamples = 10;

%antrenare
MBS=13;
NEP=11;

%dimensiuni exemple intrare
C=1;% nr canale culoare
V = 49; M = 301; N = 301;
filterSize = [5 5 3];
inputSize = [M N V]; %conv3Dseparat pe fiecare valoare de intarre, appi conv

%% date
% ordoneaza fisierele in dsTrainIm
% fileList = dir(fullfile(pathData, '*.mat'));
% fileNames = {fileList.name}';
% fileDates = [fileList.datenum]';
% [~,sortedIndices] = sort(fileDates);
% sortedFileNames = fileNames(sortedIndices);

fileList = dir(fullfile(pathData, 'image*.mat')); % Listăm doar fișierele cu nume de tipul 'imageX.mat'
fileNames = {fileList.name}';

% Extragem numerele din numele fișierelor folosind expresii regulate
fileNumbers = cellfun(@(x) sscanf(x, 'image%d.mat'), fileNames);

% Sortăm fișierele după numerele extrase
[~, sortedIndices] = sort(fileNumbers);
sortedFileNames = fileNames(sortedIndices);

dsTrainIm = fileDatastore(fullfile(pathData, sortedFileNames),'ReadFcn',@sampleMatReader);
Nold = numel(dsTrainIm.Files);
reset(dsTrainIm);
threshold = 1000;
[dsTrainIm, target_class_training, vector, scrapped] = dataFixFun(dsTrainIm, target_class_training, threshold, pathData, sortedFileNames);

% cd(pathData);
% for i=1:numel(dsTrainIm.Files)
%     disp("iteration: "); disp(i);
%     images = load(dsTrainIm.Files{i});
%     images = log(images.images);
%     varName = ['image', num2str(i)]; % Construct unique variable name
%     save([varName, '.mat'], 'images'); % Save each image in a separate MAT fill
% end

dsTrainLabels = arrayDatastore(target_class_training');
dsTrain=combine(dsTrainIm,dsTrainLabels);

reset(dsTrainIm);
N = numel(dsTrainIm.Files);
medie = read(dsTrainIm)/N;
for i=2:N
    medie = medie+read(dsTrainIm)/N;
end

% [min(medie, [], 'all') max(medie, [], 'all')];

L = image3dInputLayer(inputSize,'Name','in1','Normalization','zerocenter','Mean',medie);
%% arhitecturi cu 3D conv
% layerG=[image3dInputLayer(inputSize,'Name','in1')
%     convolution3dLayer(filterSize,numFilters(1),'Name','cv', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn')
%     reluLayer('Name','rl1')
%     maxPooling3dLayer([3 3 3],'Stride', [3 3 3],'Name','pool1')
%     convolution3dLayer(filterSize,numFilters(2),'Name','cv2', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn2')
%     reluLayer('Name','rl2')
%     maxPooling3dLayer([3 3 3],'Stride', [3 3 3],'Name','pool2')
%     convolution3dLayer(filterSize,numFilters(3),'Name','cv3', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn3')
%     reluLayer('Name','rl3')
%     maxPooling3dLayer([3 3 3],'Stride', [3 3 3],'Name','pool3')
%     dropoutLayer('Name','drop1')
%     fullyConnectedLayer(numHiddenUnits(1), 'Name','fc1') % numHidden1
%     reluLayer('Name','rl4')
%     dropoutLayer('Name','drop2')
%     fullyConnectedLayer(numHiddenUnits(2), 'Name','fc2') % numHidden1
%     reluLayer('Name','rl5')
%     dropoutLayer('Name','drop')
%     fullyConnectedLayer(numClasses, 'Name','fc')
%     reluLayer('Name','rl')
%     softmaxLayer('Name','softmax')
%     classificationLayer('Name','classification')];

layerG=[ L
    batchNormalizationLayer('Name','bn0') %instanceNormalizationLayer
    convolution3dLayer(filterSize,numFilters(1),'Name','cv', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn')
    reluLayer('Name','rl1')
    maxPooling3dLayer([4 4 3],'Stride', [4 4 3],'Name','pool1')
    convolution3dLayer(filterSize,numFilters(2),'Name','cv2', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn2')
    reluLayer('Name','rl2')
    maxPooling3dLayer([4 4 3],'Stride', [4 4 3],'Name','pool2')
    convolution3dLayer(filterSize,numFilters(3),'Name','cv3', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn3')
    reluLayer('Name','rl3')
    maxPooling3dLayer([3 3 3],'Stride', [3 3 3],'Name','pool4')
    dropoutLayer('Name','drop1')
    fullyConnectedLayer(numHiddenUnits(1), 'Name','fc1') % numHidden1
    reluLayer('Name','rl4')
    dropoutLayer('Name','drop2')
    fullyConnectedLayer(numHiddenUnits(2), 'Name','fc2') % numHidden1
    reluLayer('Name','rl5')
    dropoutLayer('Name','drop')
    fullyConnectedLayer(numClasses, 'Name','fc')
    reluLayer('Name','rl')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];

analyzeNetwork(layerG)

%% antrenare
options = trainingOptions('adam', ...
    'MiniBatchSize',MBS, ...,
    'MaxEpochs',NEP,...,
    'InitialLearnRate',0.001, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false);

net=trainNetwork(dsTrain,layerG,options);
feval(@save, 'res.mat', 'net');
% save('res.mat', "net");

