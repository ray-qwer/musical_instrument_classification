[x1,fs1] = audioread("clarnet.aiff");
dtau = 0.005;
[X1, t, f] = STFT(x1, fs1, 4000);
figure(1);
subplot(2,1,1);
image(t,f,abs(X1)/max(max(abs(X1)))*1000);colormap(gray(256));set(gca,'Ydir','normal');set(gca,'Fontsize',12);
xlabel('Time (Sec)','Fontsize',12);ylabel('Frequency (Hz)','Fontsize',12);title('STFT of x(t)','Fontsize',12);

X_in1 = INST_FREQ(X1);
subplot(2,1,2);
image(t,f,X_in1*1000);colormap(gray(256));set(gca,'Ydir','normal');set(gca,'Fontsize',12);
xlabel('Time (Sec)','Fontsize',12);ylabel('Frequency (Hz)','Fontsize',12);title('STFT of x(t)','Fontsize',12);

dot_counts = 0;
freq_factor = [1:3];
E_har = zeros(1,freq_factor(end));
E_all = 0;
for t = [1:size(X_in1,2)]
    if max(X_in1(:,t)) == 0
        continue;
    end
    [mag,f] = max(X_in1(:,t),[],"all");
    f_array = find(X_in1 == mag);
    if ~isempty(f_array)
        f_0 = f_array(2) - f_array(1);
        if abs(f_0 - f_array(1)) / f_array(1) > 0.1
            f = f_0;
        end
    else
        f = f_array(1);
    end
    upper = round((freq_factor+0.5).*f); lower = round((freq_factor-0.5).*f);
    upper(upper > size(X_in1,1)) = size(X_in1,1);
    lower(lower > size(X_in1,1)) = size(X_in1,1);
    E_tmp = X1(:,t).^2;
    for i = 1:size(E_har, 2)
        E_har(i) = E_har(i) + sum(E_tmp(lower(i):upper(i)));
    end
    E_all = E_all + sum(E_tmp);
    dot_counts = dot_counts+1;
end

E_all = E_all / dot_counts;
E_har = E_har./ dot_counts;
