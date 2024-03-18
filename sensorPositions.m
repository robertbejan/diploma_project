function pozitiiSenzori = sensorPositions(infoFeatFFT, data_meg)
    pozitiiSenzori = cell(1,3);
    for i=1:numel(infoFeatFFT(1).sensors)
        sensorName = infoFeatFFT(1).sensors{i, 1};
        index_label = find(strcmp(data_meg.grad.label, sensorName));
        x_axis = data_meg.grad.chanpos(index_label, 1);
        y_axis = data_meg.grad.chanpos(index_label, 2);
        pozitiiSenzori{i,1} = sensorName;
        pozitiiSenzori{i,2} = x_axis;
        pozitiiSenzori{i,3} = y_axis;
    end
end