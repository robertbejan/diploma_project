clear all
close all
clc
pathData='K:\Work\Lavinia\Robert\date_antrenare_2-20240406T071825Z-001\date_antrenare_2\data';
pathMain='K:\Work\Lavinia\Robert\scripturi_antrenare-20240406T071731Z-001\scripturi_antrenare';
% addpath 
cd(pathMain)
load('K:\Work\Lavinia\Robert\date_antrenare_2-20240406T071825Z-001\date_antrenare_2\target_class_training.mat');

%% Parametri
% arhitectura

% numFilters = [16 32 32];
% numHiddenUnits = [64 32];
numClasses = 2;
numSamples = 10;



%dimensiuni exemple intrare
V = 30; M = 200; N = 200;
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

N = numel(dsTrainIm.Files);
dsTrainIm=transform(dsTrainIm, @(x) [reduceDepth(imresize(x,inputSize(1:2)),V)]);
dsTrainLabels = arrayDatastore(target_class_training');
dsTrain=combine(dsTrainIm,dsTrainLabels);

reset(dsTrainIm);
medie = read(dsTrainIm)/N;
for i=2:N
    medie = medie+read(dsTrainIm)/N;
end
reset(dsTrainIm);

[min(medie, [], 'all') max(medie, [], 'all')];

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

numFilters = [32 32 16];
numHiddenUnits = [32 32];
filterSize = [3 3 3];

%L = image3dInputLayer(inputSize,'Name','in1','Normalization','zerocenter','Mean',medie);
L = image3dInputLayer(inputSize,'Name','in1','Normalization','none');
layerG=[ L
    instanceNormalizationLayer('Name','bn0') %instanceNormalizationLayer
    %crossChannelNormalizationLayer(2, 'Name','bn0')
    convolution3dLayer(filterSize,numFilters(1),'Name','cv', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn')
    reluLayer('Name','rl1')
    maxPooling3dLayer([4 4 2],'Stride', [4 4 2],'Name','pool1')
    convolution3dLayer(filterSize,numFilters(2),'Name','cv2', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn2')
    reluLayer('Name','rl2')
    maxPooling3dLayer([4 4 2],'Stride', [4 4 2],'Name','pool2')
    convolution3dLayer(filterSize,numFilters(3),'Name','cv3', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn3')
    reluLayer('Name','rl3')
    maxPooling3dLayer([2 2 2],'Stride', [2 2 2],'Name','pool4')
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



% L = imageInputLayer(inputSize,'Name','in1','Normalization','none');

% layerG=[ L
%     %batchNormalizationLayer('Name','bn0') %instanceNormalizationLayer
%     convolution2dLayer(filterSize,numFilters(1),'Name','cv', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn')
%     reluLayer('Name','rl1')
%     maxPooling2dLayer([2 2 ],'Stride', [2 2 ],'Name','pool1')
%     convolution2dLayer(filterSize,numFilters(2),'Name','cv2', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn2')
%     reluLayer('Name','rl2')
%     maxPooling2dLayer([2 2 ],'Stride', [2 2 ],'Name','pool2')
% %     convolution3dLayer(filterSize,numFilters(3),'Name','cv3', "Padding","same") %lucreaza separat pe fiecare volum din secventa
% %     batchNormalizationLayer('Name','bn3')
% %     reluLayer('Name','rl3')
% %     maxPooling3dLayer([3 3 3],'Stride', [3 3 3],'Name','pool4')
%     dropoutLayer('Name','drop1')
%     fullyConnectedLayer(numHiddenUnits(1), 'Name','fc1') % numHidden1
%     reluLayer('Name','rl4')
% %     dropoutLayer('Name','drop2')
% %     fullyConnectedLayer(numHiddenUnits(2), 'Name','fc2') % numHidden1
% %     reluLayer('Name','rl5')
%     dropoutLayer('Name','drop')
%     fullyConnectedLayer(numClasses, 'Name','fc')
%     reluLayer('Name','rl')
%     softmaxLayer('Name','softmax')
%     classificationLayer('Name','classification')];


analyzeNetwork(layerG)

%% antrenare
%antrenare
MBS=50;
NEP=100;
options = trainingOptions('adam', ...
    'MiniBatchSize',MBS, ...,
    'MaxEpochs',NEP,...,
    'InitialLearnRate',0.0002, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false);

net=trainNetwork(dsTrain,layerG,options);
filename=['res3D_','V',num2str(V),'_E',num2str(NEP),'_MBS',num2str(MBS),'.mat'];

feval(@save, filename, 'net');
% save('res.mat', "net");

