% script pentru a naviga prin directoare si a extrage datele meg
clear

addpath D:\Facultate\Licenta\fieldtrip-20231015\fieldtrip-20231015
ft_defaults

% definirea directorului de baza
baseDir = 'D:\Facultate\Licenta\meg data test';

% se listeaza toatea subdirectoarele (sub-xxxx)
subjectDirs = dir(fullfile(baseDir, 'sub-*'));


for subjectIdx = 1:length(subjectDirs) % bucla pentru toate directoarele cu subiecti
    subjectData = struct(); % se creaza o structura in care se vor gasi datele pentru subiecti
    subjectDir = subjectDirs(subjectIdx).name; % numele subiectului de la iteratia curenta
    subjectPath = fullfile(baseDir, subjectDir); % path-ul subiectului de la iteratia curenta

    % se creeaza o variabila care stocheaza numele. al doilea parametru
    % specifica ce NU dorim sa fie inlocuit (negare ^)
    subjectName = regexprep(subjectDir, '[^a-zA-Z0-9_]', '_');

    % se adauga o noua structura pentru subiectul nostru in structura
    % subjectData daca nu se regaseste deja
    if ~isfield(subjectData, subjectName)
        subjectData.(subjectName) = struct();
    end

    % se listeaza toate sesiunile pentru subiectul respectiv
    sessionDirs = dir(fullfile(subjectPath, 'ses-*'));

    for sessionIdx = 1:length(sessionDirs)
        sessionDir = sessionDirs(sessionIdx).name;
        sessionPath = fullfile(subjectPath, sessionDir);

        % aceeasi situatie de mai sus doar ca pentru sesiuni
        sessionName = regexprep(sessionDir, '[^a-zA-Z0-9_]', '_');

        % cauta directoare meg in fiecare sesiuni
        megDir = fullfile(sessionPath, 'meg');

        if exist(megDir, 'dir')
            % daca exista, va cauta inregistrarile .ds
            restMegFiles = dir(fullfile(megDir, '*rest_run*.ds'));

            for megIdx = 1:length(restMegFiles)
                restMegFile = restMegFiles(megIdx).name;
                restMegFilePath = fullfile(megDir, restMegFile);

                if exist(restMegFilePath, 'file')
                    % Console print
                    fprintf('Processing rest MEG data file: %s\n', restMegFilePath);

                    channel_types_to_keep = {'meggrad', 'magnetometer'};
                    desired_num_trials = 30;

                    % Import  data
                    cfg = [];
                    cfg.dataset = restMegFilePath;
                    cfg.continuous = 'no';
                    data_meg = ft_preprocessing(cfg);

                    % Se face ferastruirea

                    cfgdwn.resamplefs = 240;
                    cfgdwn.channel = ft_channelselection(channel_types_to_keep, data_meg.label);
                    data_meg = ft_selectdata(cfgdwn, data_meg);
                    data_meg = ft_resampledata(cfgdwn,data_meg);

                    if numel(data_meg.trial) == 300
                        data_meg = trialResize(data_meg);
                    else
                        fprintf('The number of trials is not 300. No trial reduction is performed.\n');
                    end

                    % Se amplifica semnalul cu 10^12
                    for i = 1:numel(data_meg.trial)
                        data_meg.trial{1,i} = data_meg.trial{1,i}*10^12;
                    end

                    % Se scade numarul de canale
                    numMinCanale = 240;
                    data_meg = trialChannelSelection(data_meg, numMinCanale);

                    % Se aplica preprocesarea
                    valStart = 50;
                    data_meg = trialPreprocessing(data_meg,valStart,cfgdwn.resamplefs);

                    % se adauga datele meg la fiecare sesiune a fiecarui subiect
                    subjectData.(subjectName).(sessionName){megIdx} = data_meg;

                    save(fullfile(baseDir, subjectDir, [sessionName '_data_meg']), 'data_meg');

                else
                    fprintf('File does not exist: %s\n', restMegFilePath);
                end
            end
        end
    end
    save(fullfile(baseDir, subjectDir, 'subjectData.mat'), 'subjectData');
    fprintf('datele au fost salvate');

    close all;
    
end