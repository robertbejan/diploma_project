clear all
close all
clc
pathData='F:\Training Saves\lavinia training\Rez & Scripts Apr 9';
addpath 'D:\Facultate\Licenta\licenta_git\diploma_project'
cd(pathData)
trainedNet = load('resAlex2CNN3D_V1_E200_MBS50fullFrame.mat');
pathData = 'F:\Training Saves\lavinia training\Rez & Scripts Apr 9\rezultate\testare\dateFullFrame';
pathMain = 'F:\Training Saves\Workspace_Topo_2024-04-11_14-08_1000_testare';
cd(pathMain)
load('target_class_training.mat');

%% date
V = 1; M = 8; N = 8;
inputSize = [M N V]; %conv3Dseparat pe fiecare valoare de intarre, appi conv


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

reset(dsTrainIm);
N = numel(dsTrainIm.Files);
% dsTrainIm=transform(dsTrainIm, @(x) [reduceDepth(imresize(x,inputSize(1:2)),V)]);
dsTrainLabels = arrayDatastore(target_class_training');
dsTrain=combine(dsTrainIm,dsTrainLabels);

reset(dsTrainIm);

%% testare

net = trainedNet.net;

output = predict(net, dsTrain);

actualLabels = double(target_class_training) - 1;

[~, predictedLabels] = max(output, [], 2);
predictedLabels = predictedLabels - 1;

confMat = confusionmat(actualLabels, predictedLabels');
accuracy = sum(diag(confMat)) / sum(confMat(:)) * 100;

cd('F:\Training Saves\lavinia training\Rez & Scripts Apr 9\rezultate\testare');
save('resAlex2CNN3D_V1_E200_MBS50fullFrame.mat');