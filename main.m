% script pentru a naviga prin directoare si a extrage datele meg

addpath D:\Facultate\Licenta\fieldtrip-20231015\fieldtrip-20231015
ft_defaults

% definirea directorului de baza
baseDir = 'D:\Facultate\Licenta\meg data test';

% se listeaza toatea subdirectoarele (sub-xxxx)
subjectDirs = dir(fullfile(baseDir, 'sub-*'));

% se creaza o structura in care se vor gasi datele pentru subiecti
subjectData = struct();

for subjectIdx = 1:length(subjectDirs) % bucla pentru toate directoarele cu subiecti
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
                    % printeaza in consola faptul ca se proceseaza datele MEG
                    fprintf('Processing rest MEG data file: %s\n', restMegFilePath);
                    
                    channel_types_to_keep = {'meggrad', 'magnetometer'};
                    desired_num_trials = 30;

                    % se importa datele in continuu
                    cfg = [];
                    cfg.dataset = restMegFilePath;
                    cfg.continuous = 'no';
                    data_meg = ft_preprocessing(cfg);

                    % ferastruire
                    % if numel(data_meg.trial) == 300
                    %     asd
                    % end
                    cfgdwn.resamplefs = 1000;
                    cfgdwn.channel = ft_channelselection(channel_types_to_keep, data_meg.label);
                    data_meg = ft_selectdata(cfgdwn, data_meg);
                    data_meg = ft_resampledata(cfgdwn,data_meg);
                    

                    % se adauga datele meg la fiecare sesiune a fiecarui subiect
                    subjectData.(subjectName).(sessionName){megIdx} = data_meg;
                   
                else
                    fprintf('File does not exist: %s\n', restMegFilePath);
                end
            end
        end
    end
end
