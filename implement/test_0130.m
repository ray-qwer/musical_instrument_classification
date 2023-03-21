clear;  clc;
load features_17instruments_0203.mat;
data = features_17instruments_0203;
features = cell2mat([data(:,1)]);
label = cell2mat([data(:,2)]);
sources = string(data(:,3));
anchors = cell2mat(data(:,4));

[m,~] = find(isnan(features));
m = unique(m);
%% 
test= 2941;
disp(sources(test));
features(test,:)
[x,fs] = audioread(sources(test));
x = x(:,1).';
anchor = getAnchor(x,fs);
stop_time = anchor(anchors(test));
if anchors(test) == 1
    start_time = 1;
else 
    start_time = anchor(anchors(test)-1);
end
figure(1);
plot([1:stop_time-start_time+1]/fs,x(start_time:stop_time));

figure(4);
plot([1:length(x)]/fs, x);

[X,t,f] = STFT(x(start_time:stop_time),fs,4000);
figure(2);
image(t,f, X/max(X,[],"all")*400); colormap(gray(256)); set(gca,'Ydir','normal');

X_inst = INST_FREQ(X);
figure(3);
image(t,f, X_inst/max(X_inst,[],"all")*400); colormap(gray(256)); set(gca,'Ydir','normal');
disp(max(max(X_inst)));