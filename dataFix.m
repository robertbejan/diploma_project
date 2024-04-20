load("res.mat"); % load la network
load("target_class_training.mat");
N = numel(dsTrainIm.Files);
reset(dsTrainIm);
table = tabulate(target_class_training);
n0 = table{1, 2}; n1 = table{2, 2};

% daca apare eroarea "Scalar structure required for this assignment" trebuie
% sterse clasa0 si clasa1 din workspace
clear clasa0 clasa1;
clasa0.min = []; clasa0.max = []; clasa0.mean = [];
clasa1.min = []; clasa1.max = []; clasa1.mean = [];
indx0 = 0; indx1 = indx0; % index pentru fiecare structura clasa0 si clasa1
for i=1:N
    disp("iteration"); disp(i);
    im = read(dsTrainIm);
    a1 = activations(net,im,net.Layers(1).Name); % 3DInputLayer
    a2 = activations(net,im,net.Layers(2).Name); % Conv3D
    a3 = activations(net,im,net.Layers(6).Name); % Conv3D
    a4 = activations(net,im,net.Layers(10).Name); % Conv3D
    a5 = activations(net,im,net.Layers(13).Name); % MaxPool3D
    a = {im a1 a2 a3 a4 a5};
    minarray = []; maxarray = []; meanarray = [];
    if target_class_training(i) == categorical(1)
        indx1 = indx1 + 1;
        disp("class1"); disp(i);
        % pe fiecare element din cellarray se va gasi un array cu 5 elemente (ex. pt clasa1(1).min = [min(a1) .. min(a5)])
        for j=1:5 
            aux = a{j};
            for p=1:size(aux,3)
                minarray(p) = min(aux(:,:,p),[],'all');
                maxarray(p) = max(aux(:,:,p),[],'all');
                meanarray(p) = mean(aux(:,:,p),'all');
            end
            clasa1(indx1).min(j) = min(minarray);
            clasa1(indx1).max(j) = max(maxarray);
            clasa1(indx1).mean(j) = mean(meanarray);
        end
    else
        disp("class0"); disp(i);
        indx0 = indx0 + 1;
        for j=1:5
            aux = a{j};
            for p=1:size(aux,3)
                minarray(p) = min(aux(:,:,p),[],'all');
                maxarray(p) = max(aux(:,:,p),[],'all');
                meanarray(p) = mean(aux(:,:,p),'all');
            end
            clasa0(indx0).min(j) = min(minarray);
            clasa0(indx0).max(j) = max(maxarray);
            clasa0(indx0).mean(j) = mean(meanarray);
        end
    end
end
