clear; clc;
% instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax"];
% instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax","tuba","horn","bassTrombone",...
%     "cello","viola","doubleBass","altosax","bassflute","bassoon","Bbclarnet","flute","oboe"];
string_instrument = ["violin","viola","doubleBass","cello"];
brass_instrument = ["trumpet","tuba","horn","bassTrombone"];
woodwind_instrument = ["Ebclarnet","sopsax","altosax","bassflute","bassoon","Bbclarnet","flute","oboe"];
percussion_instrument = ["piano"];
instrument_name = [percussion_instrument, string_instrument, brass_instrument, woodwind_instrument];
string_instrument = ["violin","viola","doubleBass","cello"];
files = string(zeros(2,0));
% get all files
for i = 1:length(instrument_name)
    [lists, loc] = getInstrumentFile(instrument_name(i), "..\music_samples");
    if any(instrument_name(i) == string_instrument)
        [lists, loc] = getInstrumentFile("arco",loc);
    end
    l = string(zeros(2, length(lists)));
    for j = 1:length(lists)
        l(:,j) = [loc+"\"+lists(j).name, instrument_name(i)];
    end
    files = cat(2, files, l);
end
%% output = [f_0_max,c_mean(2:3), ave_residual,E_feature(1:4), ave_energy_ratio(10:10:100), E_stable(1:3)];
features_17instruments_0203 = cell(0,4);
fileID = fopen('log_0203.txt','w');
for i = 1:size(files,2)
    [x, fs] = audioread(files(1,i));
    x = x(:,1).';
    anchor = getAnchor(x,fs);
    start_index = 1;
    disp(['the ',num2str(i),'files: ',files(1,i)]);
    l = cell(length(anchor),4);
    for j = 1:length(anchor)
        x_seg = x(start_index:anchor(j));
        start_index = anchor(j);
        try
            outputs = getFeature(x_seg, fs);
        catch 
            l{j,1} = 0;
            l{j,2} = 0;
            l{j,3} = 0;
            l{j,4} = 0;
            fprintf(fileID,'error: %s, %d th segment, start at %4.4f, long %4.4f seconds\n', ...
                files(1,i),j,start_index/fs,length(s_seg)/fs);
            continue;
        end
        l{j,1} = outputs;
        l{j,2} = find(instrument_name == files(2,i));
        l{j,3} = files(1,i);
        l{j,4} = j;
    end
    features_17instruments_0203 = cat(1, features_17instruments_0203, l);
end
fclose(fileID);
save features_17instruments_0203.mat features_17instruments_0203;
