addpath 'D:\Facultate\Licenta\licenta_git\diploma_project'

sizeOfFeatFFT = 1000;
valStart = 50;
numOfSensors = 250;

[featFFT, infoFeatFFT, target_class_training] = trainingMatrix(sizeOfFeatFFT,valStart, numOfSensors);
[featmatTest, infoFeatTest] = trainingMatrix(sizeOfFeatFFT, valStart, numOfSensors);

[featFFT,featmatTest,infoFeatFFT,infoFeatTest] = featCorrections(featFFT,featmatTest,infoFeatFFT,infoFeatTest);

noTrees = 150;

% Construirea modelului de invatare automata utilizând caracteristicile extrase din 
% semnalele sau datele din setul de antrenare (featFFT) și etichetele
% corespunzătoare ale claselor (target_class_training)
modelC=fitensemble(featFFT,target_class_training,'Bag', noTrees,'Tree','type','classification');

% Predictiile modelului cu datele de antrenare
y_model_train = predict(modelC,featFFT);

% Predictiile modelului cu datele de antrenare
y_model_test = predict(modelC,featmatTest);

% salvare
directoryPath = 'F:\Training Saves'; 
cd(directoryPath);
currentDateTime = datestr(now, 'yyyy-mm-dd_HH-MM');
folderName = ['Workspace_', currentDateTime, '_', num2str(sizeOfFeatFFT)];

% Create the directory if it doesn't exist
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

save(fullfile(folderName, 'workspace_variables.mat'));

beep on; beep;

plot(y_model_train, 'r');
hold on;
plot(target_class_training, 'b');

target_class_trainingTest = categorical([infoFeatTest.class]);

true_labels_train = target_class_training;
true_labels_test = target_class_trainingTest;

% accuracy_train = sum(y_model_train == true_labels_train) / numel(true_labels_train);
% fprintf('Accuracy on Training Data: %.2f%%\n', accuracy_train * 100);
% 
% accuracy_test = sum(y_model_test == true_labels_test) / numel(true_labels_test);
% fprintf('Accuracy on Test Data: %.2f%%\n', accuracy_test * 100);

conf_matrix_train = confusionmat(true_labels_train, y_model_train);
disp('Confusion Matrix (Training Data):');
disp(conf_matrix_train);

conf_matrix_test = confusionmat(true_labels_test, y_model_test);
disp('Confusion Matrix (Test Data):');
disp(conf_matrix_test);
