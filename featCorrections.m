function [featFFT,featmatTest,infoFeatFFT,infoFeatTest] = featCorrections(featFFT,featmatTest,infoFeatFFT,infoFeatTest)

nonZeroRows = ~all(featFFT == 0, 2);
featFFT = featFFT(nonZeroRows, :);
nonZeroRows = ~all(featmatTest == 0, 2);
featmatTest = featmatTest(nonZeroRows, :);

infoFeatFFT = infoFeatFFT(all(~cellfun(@isempty,struct2cell(infoFeatFFT))));
infoFeatTest = infoFeatTest(all(~cellfun(@isempty,struct2cell(infoFeatTest))));

end