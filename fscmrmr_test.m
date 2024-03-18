% [idxfscmrmr, scoresfscmrmr] = fscmrmr(featFFT, target_class_training);
% 
% [idx, weight] = relieff(featFFT, target_class_training, 10);

% a = fix(idxfscmrmr(3*end/4:end)/49);
a = rem(idxfscmrmr(3*end/4:end),49);
tabulate(a)

unique_values = unique(a);
[counts, edges] = histcounts(a, 'BinMethod', 'integers');

plot(counts);
