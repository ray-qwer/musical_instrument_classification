[x, fs] = audioread("trumpet.aiff");
x= x(:,1).';

% outputs = getFeature(x,fs);
tic;
[GT,t,f] = STFT(x, fs, 4000);
toc;
% t = [0:length(x)-1]./fs; f= 0:4000;
figure(1);
image(t,f,abs(GT)/max(max(abs(GT)))*400);colormap(gray(256));set(gca,'Ydir','normal');set(gca,'Fontsize',12);
xlabel('Time (Sec)','Fontsize',12);ylabel('Frequency (Hz)','Fontsize',12);title('STFT of x(t)','Fontsize',12);

tic;
X_inst = INST_FREQ(GT);
toc;

figure(2);
image(t,f,abs(X_inst)/max(max(abs(X_inst)))*400);colormap(gray(256));set(gca,'Ydir','normal');set(gca,'Fontsize',12);
xlabel('Time (Sec)','Fontsize',12);ylabel('Frequency (Hz)','Fontsize',12);title('STFT of x(t)','Fontsize',12);