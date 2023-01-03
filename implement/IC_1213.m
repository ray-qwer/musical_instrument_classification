% Instrument name: piano, trumpet, violin, Ebclarnet, sopsax
instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax"];
files = string(zeros(2,0));
% get all files
for i = 1:length(instrument_name)
    [lists, loc] = getInstrumentFile(instrument_name(i), "..\music_samples");
    if instrument_name(i) == "violin"
        [lists, loc] = getInstrumentFile("arco",loc);
    end
    l = string(zeros(2, length(lists)));
    for j = 1:length(lists)
        l(:,j) = [loc+"\"+lists(j).name, instrument_name(i)];
    end
    files = cat(2, files, l);
end

features_5instruments = cell(size(files,2),2);
for i = 1:size(files,2)
    outputs = getFeature(files(1,i));
    features_5instruments{i,1} = outputs;
    features_5instruments{i,2} = files(2,i);
end

save features_5instruments.mat features_5instruments;