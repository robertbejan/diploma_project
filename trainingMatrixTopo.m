function [featFFT, infoFeatFFT, target_class_training, pozitiiSenzori] = trainingMatrixTopo(sizeOfFeatFFT,valStart)

% Specify the path to the directory you want to explore
directoryPath = 'F:\';

% Get a list of directories within the specified folder
dirInfo = dir(directoryPath);

% Filter out only directories (excluding '.' and '..')
directories = dirInfo([dirInfo.isdir]);
directories = directories(~ismember({directories.name}, {'.', '..'}));
directories = directories(6:end);

% Get the number of directories
numDirectories = numel(directories);

% Check if there are any directories in the folder
% for i=1:sizeOfFeatFFt
if numDirectories == 0
    disp('No directories found in the specified folder.');
else
    featFFT = cell(1, sizeOfFeatFFT); % zeros(sizeOfFeatFFT, valStart*numOfSensors-numOfSensors);
    infoFeatFFT = {};
    pozitiiSenzori = {};
    for i=1:sizeOfFeatFFT

        % Generate a random index within the range of directories
        randomIndex = randi(numDirectories);

        % Get the name of the randomly selected directory
        randomDirectoryName = directories(randomIndex).name;

        % Construct the full path of the randomly selected directory
        fullPath = fullfile(directoryPath, randomDirectoryName);

        % Display the randomly selected directory
        disp(['Randomly selected directory: ' fullPath]);

        % Now you can perform operations on this randomly selected directory
        % For example, you can open it using the 'cd' command:
        cd(fullPath);

        if exist(fullfile(fullPath, 'subjectData_full.mat'), 'file') == 2
            % Load the subjectData.mat file
            loadedData = load(fullfile(fullPath, 'subjectData_full.mat'));

            % Display information or perform operations with the loaded data
            disp('Loaded subjectData_full.mat file');
            % Access the loaded variables as needed (e.g., loadedData.variableName)
        else
            disp('subjectData_full.mat file not found in the selected directory.');
        end

        % Accessing the variable within the subjectData structure
        subjectDataFields = fieldnames(loadedData.subjectData);

        % Loop through each field name to find the matching field
        matchingField = '';
        for l = 1:numel(subjectDataFields)
            fieldName = subjectDataFields{l};

            % Check if the current field matches the pattern 'sub_*'
            if startsWith(fieldName, 'sub_') || ~isempty(regexp(fieldName, '^sub_.*', 'once'))
                matchingField = fieldName;
                break; % Exit loop if a match is found
            end
        end

        if ~isempty(matchingField)
            % Access the variable within the subjectData structure using the matching field name
            data = loadedData.subjectData.(matchingField);

            % Display the value of the variable
            disp(['Value of variable ' matchingField ':']);
            disp(data);
        else
            disp('No matching variable found.');
        end

        dataFields = fieldnames(data);
        randTestRun = randi(numel(data.(dataFields{1,1})));
        data = data.(dataFields{1,1});
        data = data{1,randTestRun};

        % Y = zeros(numel(data.label), data.fsample*10);
        Y = [];
        k = 1;

        try
            randTrial = randi(numel(data.trial));
            for j=1:numel(data.label) %electrod
                Y(j,:) = fft(data.trial{1,randTrial}(j,:)');
            end
            aux = abs(Y(:,2:valStart)');
            disp(size(aux(:)'));
            featFFT{i} = aux(:)';
            disp(size(featFFT));
        catch ME
            % Handle the exception/error
            disp('An error occurred:');
            disp(ME.message); % Display the error message
            % beep on; beep;
            i = i - 1;
            if i < 1
                i = 1; % Ensure i does not become less than 1
            end
            continue;
        end

        % Creating dynamic field name   s for struct
        trialName = strcat("trial", num2str(randTrial));

        % Adding data to the struct with the dynamic field names
        infoFeatFFT(i).subject = fieldName;
        infoFeatFFT(i).trial = trialName;
        infoFeatFFT(i).sensors = data.label;
        if startsWith(fieldName, 'sub_CON')
            infoFeatFFT(i).class = 0; % Set flag to 0 if fieldName starts with 'sub_CON'
        else
            infoFeatFFT(i).class = 1;
        end
        
        cd 'D:\Facultate\Licenta\licenta_git\diploma_project'
        pozitiiSenzori{i} = sensorPositions(infoFeatFFT(i), data);

        disp('iteration: ');
        disp(i);
    end
end

target_class_training = categorical([infoFeatFFT.class]);
end