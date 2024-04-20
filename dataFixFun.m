function [dsTrainIm, target_class_training, vector, scrapped] = dataFixFun(dsTrainIm, target_class_training, threshold, pathToData, sortedFileNames)
    N = numel(dsTrainIm.Files);
    scrapped = 0;
    indx = 0; 
    indxsec = 0;
    vector = zeros(1,N);
    cd(pathToData);

    try
        while indx <= N
            aux = 0;
            indx = indx + 1;
            indxsec = indxsec + 1;
            disp("iteration"); 
            disp(indx);
            %im = read(dsTrainIm);
            im = load(sortedFileNames{indxsec});
            im = im.images;
            med = [];
            for p=1:size(im,3)
                med(p) = mean(im(:,:,p), "all");
            end
            aux = mean(med);
            vector(indx) = aux;
            % if abs(aux) > threshold
            %     dsTrainIm.Files(indx) = [];
            %     sortedFileNames{indxsec} = [];
            %     target_class_training(indx) = [];
            %     scrapped = scrapped + 1;
            %     indx = indx - 1;
            %     N = N - 1;
            % end
        end
    catch exception
        % Handle any errors here
        disp("An error occurred:");
        disp(exception.message);
        % You can add additional error handling or logging here
    end
end
