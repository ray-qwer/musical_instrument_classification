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
% output = [c_mean(2:3), ave_residual,E_feature, ave_energy_ratio(10:10:100), E_stable(1:3)];
features_5instruments_0110 = cell(0,2);
for i = 1:size(files,2)
    [x, fs] = audioread(files(1,i));
    x = x(:,1).';
    anchor = segment_anchor(x);
    start_index = 1;
    disp(["the ",i,"files"]);
    l = cell(length(anchor),2);
    for j = 1:length(anchor)
        x_seg = x(start_index:anchor(j));
        start_index = anchor(j);
        try
            outputs = getFeature(x_seg, fs);
        catch 
            l{j,1} = "error";
            l{j,2} = "error";
            disp(["error:",files(2,i),j]);
            continue;
        end
        l{j,1} = outputs;
        l{j,2} = find(instrument_name == files(2,i));
    end
    features_5instruments_0110 = cat(1, features_5instruments_0110, l);
end

save features_5instruments_0110.mat features_5instruments_0110;
