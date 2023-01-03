[x1, fs1]= audioread("piano.aiff");
dtau = 0.005;
X1 = STFT(x1, fs1, 4000);
X_inst1 = INST_FREQ(X1);
size_x = size(X_inst1);
dot_count = 0;
ave_energy_ratio = 0;
K = bwlabel(X_inst1,8);
t = 1;
while t <= size_x(2)
    if max(X_inst1(:,t)) ~= 0
        [mag,f] = max(X_inst1(:,t),[],'all');
        label = K(f,t);
        [f_label, t_label] = find(K == label);
        t_0 = min(t_label); t_1 = max(t_label); gap = t_1 - t_0;
        E0 = 0; E1 = 0;
        for t_ = [t_0: t_1]
            if t_ <= t_0 + gap * 0.1
                E0  = E0 + sum(X1(:,t_).^2);
            end
            E1 = E1 + sum(X1(:,t_).^2);
        end
        dot_count = dot_count + gap + 1;
        ave_energy_ratio = ave_energy_ratio + E0/E1 * (gap+1);
        t = t_1;
    end
    t = t+ 1;
end
ave_energy_ratio = ave_energy_ratio/ dot_count;
disp(ave_energy_ratio);