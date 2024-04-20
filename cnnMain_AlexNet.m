clear all
close all
clc
warning off
pathData='F:\Training Saves\Workspace_Topo_2024-04-05_18-44_1000\data';
pathMain='F:\Training Saves\Workspace_Topo_2024-04-05_18-44_1000\data';
addpath(pathMain)
cd(pathMain)
load('target_class_training.mat');

%% Parametri
% arhitectura

% numFilters = [16 32 32];
% numHiddenUnits = [64 32];
numClasses = 2;
numSamples = 10;



%dimensiuni exemple intrare
C=1;% nr canale culoare
V = 1; M = 227; N = 227;
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
threshold = 1500;
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

% reset(dsTrainIm);
% medie = read(dsTrainIm)/N;
% for i=2:N
%     medie = medie+read(dsTrainIm)/N;
% end
% reset(dsTrainIm);
% 
% [min(medie, [], 'all') max(medie, [], 'all')];

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



%L = image3dInputLayer(inputSize,'Name','in1','Normalization','zerocenter','Mean',medie);
% layerG=[ L
%     batchNormalizationLayer('Name','bn0') %instanceNormalizationLayer
%     convolution3dLayer(filterSize,numFilters(1),'Name','cv', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn')
%     reluLayer('Name','rl1')
%     maxPooling3dLayer([4 4 3],'Stride', [4 4 3],'Name','pool1')
%     convolution3dLayer(filterSize,numFilters(2),'Name','cv2', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn2')
%     reluLayer('Name','rl2')
%     maxPooling3dLayer([4 4 3],'Stride', [4 4 3],'Name','pool2')
%     convolution3dLayer(filterSize,numFilters(3),'Name','cv3', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn3')
%     reluLayer('Name','rl3')
%     maxPooling3dLayer([3 3 3],'Stride', [3 3 3],'Name','pool4')
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
filterSize = [3 3 ];

L = imageInputLayer(inputSize,'Name','in1','Normalization','none');

layerG=[ L
    instanceNormalizationLayer('Name','bn0') %instanceNormalizationLayer
    convolution2dLayer(filterSize,numFilters(1),'Name','cv', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn')
    reluLayer('Name','rl1')
    maxPooling2dLayer([2 2 ],'Stride', [2 2 ],'Name','pool1')
    convolution2dLayer(filterSize,numFilters(2),'Name','cv2', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn2')
    reluLayer('Name','rl2')
    maxPooling2dLayer([2 2 ],'Stride', [2 2 ],'Name','pool2')
%     convolution3dLayer(filterSize,numFilters(3),'Name','cv3', "Padding","same") %lucreaza separat pe fiecare volum din secventa
%     batchNormalizationLayer('Name','bn3')
%     reluLayer('Name','rl3')
%     maxPooling3dLayer([3 3 3],'Stride', [3 3 3],'Name','pool4')
    dropoutLayer('Name','drop1')
    fullyConnectedLayer(numHiddenUnits(1), 'Name','fc1') % numHidden1
    reluLayer('Name','rl4')
%     dropoutLayer('Name','drop2')
%     fullyConnectedLayer(numHiddenUnits(2), 'Name','fc2') % numHidden1
%     reluLayer('Name','rl5')
    dropoutLayer('Name','drop')
    fullyConnectedLayer(numClasses, 'Name','fc')
    reluLayer('Name','rl')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];


analyzeNetwork(layerG)

net=alexnet;

reset(dsTrainIm);
medie = read(dsTrainIm)/N;
for i=2:N
    medie = medie+read(dsTrainIm)/N;
end
reset(dsTrainIm);
%L1 = imageInputLayer(inputSize,'Name','in1','Normalization','zerocenter','Mean',medie);
L1 = imageInputLayer(inputSize,'Name','in1','Normalization','none');

L2Old=net.Layers(2);
W=L2Old.Weights;
for i=4:V
    z=randi([1 3]);
    W(:,:,i,:)=L2Old.Weights(:,:,z,:);
end
L2=convolution2dLayer(L2Old.FilterSize,L2Old.NumFilters,Weights=W,Bias=L2Old.Bias,Padding=L2Old.Padding,Stride=L2Old.Stride);

layersTr=net.Layers(3:end-3);
layerG=[L1
    batchNormalizationLayer
    L2
    layersTr
    fullyConnectedLayer(numClasses, 'Name','fc')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];
 
 analyzeNetwork(layerG);


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

net=trainNetwork(dsTrain,net,options);
filename=['resAlex_','V',num2str(V),'_E',num2str(NEP),'_MBS',num2str(MBS),'.mat'];
feval(@save, filename, 'net');

% save('res.mat', "net");

