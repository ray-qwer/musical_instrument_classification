[x, fs] = audioread("piano.aiff");
% X1 = STFT(x1, fs1);

[X, t, f] = STFT(x, fs, 4000);
% figure(1);
% subplot(2,1,1);
% image(t,f,abs(X)/max(max(abs(X)))*1000);colormap(gray(256));set(gca,'Ydir','normal');set(gca,'Fontsize',12);
% xlabel('Time (Sec)','Fontsize',12);ylabel('Frequency (Hz)','Fontsize',12);title('STFT of x(t)','Fontsize',12);

X_inst = INST_FREQ(X);
% subplot(2,1,2);
% image(t,f,X_inst*10000);colormap(gray(256));set(gca,'Ydir','normal');set(gca,'Fontsize',12);
% xlabel('Time (Sec)','Fontsize',12);ylabel('Frequency (Hz)','Fontsize',12);title('STFT of x(t)','Fontsize',12);

order = 2 + 1;      % prior is the one to modified, 2 for second order
epsilon = 0; c_mean = zeros(order, 1); 
dtau = 0.005;
[K, num] = bwlabel(X_inst, 8);
ave_residual = 0;
dot_counts = 0;
for label = 1:num
    [b, a] = find(K == label);
    C_array = POLY_APPRO(a, b, order, dtau);
    C_array(isnan(C_array)) = 0;
    c_mean = C_array.*length(b) + c_mean;
    residual = RESIDUAL(a, b, C_array, dtau);
    residual_abs = sum(abs(residual));
    dot_counts = dot_counts + length(b);
    ave_residual = ave_residual +residual_abs;
end

ave_residual = ave_residual/ dot_counts;
c_mean = c_mean ./ dot_counts;