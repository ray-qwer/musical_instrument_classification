%%
% instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax"];
instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax","tuba","horn","bassTrombone",...
    "cello","viola","doubleBass","altosax","bassflute","bassoon","Bbclarnet","flute","oboe"];
string_instrument = ["violin","viola","doubleBass","cello"];
%%
load features_17instruments_0114.mat;
m = zeros(1,length(features_17instruments_0114));
for i = 1:length(string_instrument)
    idx_erase = find(instrument_name == string_instrument(i));
    m =m + ([features_17instruments_0114{:,2}] == idx_erase);
end
n = [1:length(features_17instruments_0114)];
n = n(m==1);
features_17instruments_0114(n,:) = [];
%%
files = string(zeros(2,0));
% get all files
for i = 1:length(string_instrument)
    
    [lists, loc] = getInstrumentFile(string_instrument(i), "..\music_samples");
    if any(string_instrument(i) == string_instrument)
        [lists, loc] = getInstrumentFile("arco",loc);
    end
    l = string(zeros(2, length(lists)));
    for j = 1:length(lists)
        l(:,j) = [loc+"\"+lists(j).name, string_instrument(i)];
    end
    files = cat(2, files, l);
end
%% output = [f_0_max,c_mean(2:3), ave_residual,E_feature, ave_energy_ratio(10:10:100), E_stable(1:3)];
features_17instruments_0115 = features_17instruments_0114;
fileID = fopen('log_0114.txt','w');
for i = 1:size(files,2)
    [x, fs] = audioread(files(1,i));
    x = x(:,1).';
    anchor = segment_anchor(x,fs);
    start_index = 1;
    disp(['the ',num2str(i),'files: ',files(1,i)]);
    l = cell(length(anchor),2);
    for j = 1:length(anchor)
        x_seg = x(start_index:anchor(j));
        start_index = anchor(j);
        try
            outputs = getFeature(x_seg, fs);
        catch 
            l{j,1} = 0;
            l{j,2} = 0;
            fprintf(fileID,'error: %s, %d th segment, %d dots\n',files(1,i),j,length(x_seg));
            continue;
        end
        l{j,1} = outputs;
        l{j,2} = find(instrument_name == files(2,i));
    end
    features_17instruments_0115 = cat(1, features_17instruments_0115, l);
end
fclose(fileID);
save features_17instruments_0115.mat features_17instruments_0115;
