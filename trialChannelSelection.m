function [data_meg] = trialChannelSelection(data_meg, numMin)
% Stabilesc electrozi alesi

% Se determina senzorii importanti
i = 1;
if i==1
    dispersii = std(data_meg.trial{1,i}');
    [~, idxSorted] = sort(dispersii);
    idxSel = idxSorted(1:numMin);
    [v2, ~] = sort(idxSel);
end

% Se modifica semnalul ca sa contina canalele importante
for i = 1:30
    data_meg.trial{1,i} = data_meg.trial{1,i}(v2,:);
end

% Se modifica numele canalelor
for j = 1:numMin
    labels(1,j) = data_meg.label(v2(1,j));
end

data_meg.label = labels';

fprintf("Channeles have been minimized\n");

end