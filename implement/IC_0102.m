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

features_5instruments = cell(0,2);
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
    features_5instruments = cat(1, features_5instruments, l);
end

save features_5instruments.mat features_5instruments;
% plot(t, x);
% hold on;
% threshold_silence = 0;
% threshold_noisy = 0.001;
% state_count_thr = 50;
% state = false; % state: false is silence, true is playing
% state_count =0;
% state_1to0 = [];
% for i= 1:length(x)
%     if state == 0
%         if abs(x(i)) > threshold_noisy
%             state_count = state_count +1;
%         else 
%             state_count = 0;
%         end
%     else
%         if(abs(x(i))) <= threshold_silence
%             state_count = state_count +1;
%         else
%             state_count = 0;
%         end
%     end
%     if state_count > state_count_thr
%         if state
%             state_1to0 =[state_1to0, i-state_count-30];
%         end
%         state = ~state;
%         state_count = 0;
%     end
% end
% state_1to0(end) = length(x);
% yl = ylim;
% for i = 1:length(state_1to0)
%     plot([state_1to0(i), state_1to0(i)],yl,"r");
% end
% hold off;