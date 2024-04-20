clear all
close all
clc
warning off
pathData='F:\Training Saves\Workspace_Topo_2024-04-05_18-44_1000\data';
pathMain='F:\Training Saves\Workspace_Topo_2024-04-05_18-44_1000';
addpath('D:\Facultate\Licenta\licenta_git\diploma_project\');
addpath(pathMain)
cd(pathMain)
load('target_class_training.mat');

%% Parametri
% arhitectura
numClasses = 2;

%dimensiuni exemple intrare
C=1;% nr canale culoare
V = 49; M = 227; N = 227;
inputSize = [M N V]; %conv3Dseparat pe fiecare valoare de intarre, appi conv

%% date
fileList = dir(fullfile(pathData, 'image*.mat')); % Listăm doar fișierele cu nume de tipul 'imageX.mat'
fileNames = {fileList.name}';

fileNumbers = cellfun(@(x) sscanf(x, 'image%d.mat'), fileNames);

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
reset(dsTrainIm);
cd('F:\Training Saves\lavinia training\Rez & Scripts Apr 9');
net = load('resAlex_V49_E100_MBS50.mat');
net = net.net;
cd('F:\Training Saves\lavinia training\Rez & Scripts Apr 9\rezultate\testare\dateFullFrame');
for i=1:N
    x = load(dsTrainIm.UnderlyingDatastores{1, 1}.Files{i, 1});
    x = x.images;
    % for j=1:49
        images = activations(net,x,'pool5');
        images = sum(images,3);
        % images = x(:,:,j);
        disp("iteration: "); disp(i);
        varName = ['image', num2str(i)]; % Construct unique variable name
        save([varName, '.mat'], 'images'); % Save each image in a separate MAT fill
    % end
end
reset(dsTrainIm);

%% arhitecturi

numFilters = [16 16 16];
numHiddenUnits = [32 32];
filterSize = [3 3 9];

%L = image3dInputLayer(inputSize,'Name','in1','Normalization','zerocenter','Mean',medie);
L = image3dInputLayer(inputSize,'Name','in1','Normalization','none');
layerG=[ L
    instanceNormalizationLayer('Name','bn0') %instanceNormalizationLayer
    %crossChannelNormalizationLayer(2, 'Name','bn0')
    convolution3dLayer(filterSize,numFilters(1),'Name','cv', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn')
    reluLayer('Name','rl1')
    % maxPooling3dLayer([1 1 2],'Stride', [1 1 2],'Name','pool1')
    convolution3dLayer(filterSize,numFilters(2),'Name','cv2', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    batchNormalizationLayer('Name','bn2')
    reluLayer('Name','rl2')
    % maxPooling3dLayer([2 2 4],'Stride', [2 2 4],'Name','pool2')
    % convolution3dLayer(filterSize,numFilters(3),'NamSe','cv3', "Padding","same") %lucreaza separat pe fiecare volum din secventa
    % batchNormalizationLayer('Name','bn3')
    % reluLayer('Name','rl3')
    % maxPooling3dLayer([1 1 2],'Stride', [2 2 2],'Name','pool4')
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
%antrenare
MBS=50;
NEP=300;
options = trainingOptions('adam', ...
    'MiniBatchSize',MBS, ...,
    'MaxEpochs',NEP,...,
    'InitialLearnRate',0.0002, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false);

net=trainNetwork(dsTrain,layerG,options);
cd('F:\Training Saves\lavinia training\Rez & Scripts Apr 9');
filename=['resAlex2CNN3D_','V',num2str(V),'_E',num2str(NEP),'_MBS',num2str(MBS),'OneFrame','.mat'];
feval(@save, filename, 'net');

