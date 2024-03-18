clear all
close all
clc
pathData='F:\Training Saves\Workspace_Topo_2024-03-18_16-05_600\data';
pathMain='F:\Training Saves\Workspace_Topo_2024-03-18_16-05_600';

%% Parametri
% arhitectura

numFilters = [16 16 16];
numHiddenUnits = [32 32];
numClasses = 2;
numSamples = 10;

%antrenare
MBS=20;
NEP=11;

%dimensiuni exemple intrare
C=1;% nr canale culoare
V = 49; M = 301; N = 301;
filterSize = [5 5 3];
inputSize = [M N V]; %conv3Dseparat pe fiecare valoare de intarre, appi conv

%% date
% ordoneaza fisierele in dsTrainIm
fileList = dir(fullfile(pathData, '*.mat'));
fileNames = {fileList.name}';
fileDates = [fileList.datenum]';
[~,sortedIndices] = sort(fileDates);
sortedFileNames = fileNames(sortedIndices);

dsTrainIm = fileDatastore(fullfile(pathData, sortedFileNames),'ReadFcn',@sampleMatReader);
cd(pathMain);
load("target_class_training.mat");
dsTrainLabels = arrayDatastore(target_class_training');
dsTrain=combine(dsTrainIm,dsTrainLabels);

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

layerG=[image3dInputLayer(inputSize,'Name','in1')
    convolution3dLayer(filterSize,numFilters(1),'Name','cv', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn')
    reluLayer('Name','rl1')
    maxPooling3dLayer([10 10 3],'Stride', [10 10 3],'Name','pool1')
    convolution3dLayer(filterSize,numFilters(2),'Name','cv2', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn2')
    reluLayer('Name','rl2')    
    maxPooling3dLayer([5 5 3],'Stride', [5 5 3],'Name','pool2')
    
    dropoutLayer('Name','drop1')
    fullyConnectedLayer(numHiddenUnits(1), 'Name','fc1') % numHidden1
    reluLayer('Name','rl4')
    dropoutLayer('Name','drop2')
    % fullyConnectedLayer(numHiddenUnits(2), 'Name','fc2') % numHidden1
    % reluLayer('Name','rl5')
    % dropoutLayer('Name','drop')
    fullyConnectedLayer(numClasses, 'Name','fc')
    reluLayer('Name','rl')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];

analyzeNetwork(layerG)

%% antrenare
options = trainingOptions('adam', ...
    'MiniBatchSize',MBS, ...,
    'MaxEpochs',NEP,...,
    'InitialLearnRate',1e-4, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false);

net=trainNetwork(dsTrain,layerG,options);