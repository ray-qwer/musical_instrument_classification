string_instrument = ["violin","viola","doubleBass","cello"];
brass_instrument = ["trumpet","tuba","horn","bassTrombone"];
woodwind_instrument = ["Ebclarnet","sopsax","altosax","bassflute","bassoon","Bbclarnet","flute","oboe"];
percussion_instrument = ["piano"];
instrument_name = [percussion_instrument];

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

%%
[x,fs] = audioread(files(1,1));
x = x(:,1);
figure(1);
spectralCentroid(x,fs);
figure(2);
spectralDecrease(x,fs);
figure(3);
spectralSkewness(x,fs);
figure(4);
spectralSpread(x,fs);