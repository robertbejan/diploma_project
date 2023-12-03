function data_meg = trialResize(data_meg)
new_trials = cell(1, numel(data_meg.trial)/10);

for i = 1:10:numel(data_meg.trial)
    trial_subset = i:i+9;
    concatenated_trial = cat(2, data_meg.trial{trial_subset});
    new_trials{(i-1)/10 + 1} = concatenated_trial;
end

% Update data_meg with the reduced trials
data_meg.trial = new_trials;
data_meg.time = data_meg.time(1:10:end); % Adjust time accordingly
data_meg.sampleinfo = zeros(2,numel(data_meg.trial))';
for i=1:numel(data_meg.trial)
    if i==1
        data_meg.sampleinfo(i,1) = i;
        data_meg.sampleinfo(i,2) = 10000;
    else
        data_meg.sampleinfo(i,1) = (i-1)*10000+1;
        data_meg.sampleinfo(i,2) =  i*10000;
    end
end
fprintf("Data has been resized\n");
end