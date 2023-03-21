% output: [c1, c2, residual(epsilon), E0/EA, E1/EA, E2/EA, E1/E0, E2/E0, E2/E1, onset_energy]
function output = getFeature(x, fs)
% [x, fs] = audioread(testFile);
if length(x) > fs*20
    if size(x,1) > size(x,2)
        x = x(1:fs*20,1);
    else
        x = x(1,1:fs*20);
    end
end

X = STFT(x, fs, 4000);


X_inst = INST_FREQ(X);


%% instataneous freq

order = 2 + 1;      % prior is the one to modified, 2 for second order
c_mean = zeros(order, 1); 
dtau = 0.005;
[K, num] = bwlabel(X_inst, 8);
ave_residual = 0;
dot_counts = 0;
for label1 = 1:num
    [b, a] = find(K == label1);
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
c_mean = c_mean.';

%% harmonic energy
dot_counts = 0;
freq_factor = [1:3];
E_har = zeros(1,freq_factor(end));
E_all = 0;
f_0_max = 8000;
for t = [1:size(X_inst,2)]
    if max(X_inst(:,t)) == 0
        continue;
    end
    [mag,f0] = max(X_inst(:,t),[],"all");
    f_array = find(X_inst(:,t) == mag,2);
    if length(f_array) > 1
        f_gap = f_array(2) - f_array(1);
        if abs(f_array(1) - f_gap) / f_array(1) > 0.1 && f_array(1) > f_gap && f_gap/f_array(1) > 0.1
            f0 = f_gap;
        end
    end
    f_0_max = min(f_0_max, f0);
    upper = round((freq_factor+0.5).*f0); lower = round((freq_factor-0.5).*f0);
    upper(upper > size(X_inst,1)) = size(X_inst,1);
    lower(lower > size(X_inst,1)) = size(X_inst,1);
    E_tmp = X(:,t).^2;
    for i = 1:size(E_har, 2)
        E_har(i) = E_har(i) + sum(E_tmp(lower(i):upper(i)));
    end
    E_all = E_all + sum(E_tmp);
    
    dot_counts = dot_counts+1;
end

E_all = E_all / dot_counts;
E_har = E_har./ dot_counts;
% E0/EA, E1/EA, E2/EA, E1/E0, E2/E0, E2/E1
E_feature = [E_har./E_all, E_har(2)/E_har(1), E_har(3)/E_har(1), E_har(3)/E_har(2)];

%% energy percentage along time
dot_counts = 0;
% ave_energy_ratio = zeros(1,6);
ave_energy_ratio = zeros(1,10);
K = bwlabel(X_inst,8);
t = 1;
while t <= size(X_inst,2)
    if max(X_inst(:,t)) ~= 0
        [~,f] = max(X_inst(:,t),[],'all');
        label1 = K(f,t);
        [~, t_label] = find(K == label1);
        t_0 = min(t_label); t_1 = max(t_label); gap = t_1 - t_0;
%         onset_6 = zeros(1,6);
        onset_10 = zeros(1,10);
        E1 = 0; pct_idx = 1;
%         exp_thr = 0.02;
        exp_thr = 0.1;
        for t_ = [t_0: t_1]
            E_tmp = sum(X(:,t_).^2);
            if t_ <= t_0 + gap * exp_thr
                onset_10(pct_idx)  = onset_10(pct_idx) + E_tmp;
            else 
                if exp_thr < 1
                    pct_idx = pct_idx + 1;
%                     exp_thr = exp_thr+2^pct_idx*0.01;
                    exp_thr = pct_idx*0.1;
                    onset_10(pct_idx) = E_tmp;
                end
            end
            E1 = E1 + E_tmp;
        end
        dot_counts = dot_counts + gap + 1;
        ave_energy_ratio = ave_energy_ratio + onset_10/E1 .* (gap+1);
        t = t_1;
    end
    t = t+ 1;
end
ave_energy_ratio = ave_energy_ratio./ dot_counts;

%% stability of f0
E_stable = zeros(1,3);

dot_counts = 0;
t= 1;
while t <= size(X_inst,2)
    if max(X_inst(:,t))~= 0
        [mag, f] = max(X_inst(:,t),[],"all");
        har_array = find(X_inst(:,t)==mag, 2);
        label1 = K(f,t);
        [f_label1, t_label1] = find(K == label1);
        f0 = mean(f_label1);
        if length(har_array) > 1
            label2 = K(har_array(2),t);
            [f_label2,~] = find(K == label2);
            f1 = mean(f_label2);
            if abs(f1-f0)/f0 > 0.1
                f0 = abs(f1-f0);
            end
        end
        E_stable_tmp = zeros(1,3);
        E_all = 0;
        for t_ = min(t_label1):max(t_label1)
            for j = 1:length(E_stable_tmp)
                E_stable_tmp(j) =E_stable_tmp(j)+ sum(X(min(fix((j-0.05)*f0),size(X_inst,1)):min(fix((j+0.05)*f0),size(X_inst,1)),t_).^2);
            end
            E_all =E_all+ sum(X(:,t_).^2);
        end
        dot_counts = dot_counts + max(t_label1)- min(t_label1)+ 1;
        E_stable = E_stable + (E_stable_tmp ./ E_all) .* (max(t_label1)-min(t_label1)+1);
        t = t_;
    end
    t=t+1;
end
E_stable = E_stable ./ dot_counts;

%%
output = [f_0_max, c_mean(2:3), ave_residual,E_feature, ave_energy_ratio, E_stable];
end