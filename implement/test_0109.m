[x, fs] = audioread("D:\lab\musical_instrument_classification\music_samples\string\cello\arco\Cello.arco.mf.sulC.C3C4.mono.aif");
x= x(:,1).';

x_ = x.^2;
filter = exp(-0.001.*([-2200:2200]./fs).^2);
x_ = conv(x_,filter,"same");
x_ = x_ * 0.8/mean(x_);
figure(1);

plot(1:length(x),x_);
hold on;
anchor = getAnchor(x,fs);
yl = ylim;
for i = 1:length(anchor)
    plot([anchor(i),anchor(i)],[yl(1), yl(2)],"-r");
end
hold off;
% anchor = segment_anchor(x,fs);
start_index = 1;
numel(anchor)
%% 
for j = 4:length(anchor)
    x_seg = x(start_index:anchor(j));
    start_index = anchor(j);
    outputs = getFeature(x_seg, fs);
end
% outputs = getFeature(x,fs);
% tic;
% [GT,t,f] = STFT(x, fs, 4000);
% toc;
% % t = [0:length(x)-1]./fs; f= 0:4000;
% figure(1);
% image(t,f,abs(GT)/max(max(abs(GT)))*400);colormap(gray(256));set(gca,'Ydir','normal');set(gca,'Fontsize',12);
% xlabel('Time (Sec)','Fontsize',12);ylabel('Frequency (Hz)','Fontsize',12);title('STFT of x(t)','Fontsize',12);
% 
% tic;
% X_inst = INST_FREQ(GT);
% toc;
% 
% figure(2);
% image(t,f,abs(X_inst)/max(max(abs(X_inst)))*400);colormap(gray(256));set(gca,'Ydir','normal');set(gca,'Fontsize',12);
% xlabel('Time (Sec)','Fontsize',12);ylabel('Frequency (Hz)','Fontsize',12);title('STFT of x(t)','Fontsize',12);
