[x, fs] = audioread("violin.aif");
if length(x) > fs*20
    x = x(1:fs*20,1);
end
X = STFT(x, fs, 4000);

X_inst = INST_FREQ(X);

% instataneous freq
order = 2 + 1;      % prior is the one to modified, 2 for second order
c_mean = zeros(order, 1); 
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
c_mean = c_mean.';

% harmonic energy
dot_counts = 0;
freq_factor = [1:3];
E_har = zeros(1,freq_factor(end));
E_all = 0;
for t = [1:size(X_inst,2)]
    if max(X_inst(:,t)) == 0
        continue;
    end
    [mag,f0] = max(X_inst(:,t),[],"all");
    f_array = find(X_inst(:,t) == mag,2);
    if length(f_array) > 1
        f_gap = f_array(2) - f_array(1);
        if abs(f_array - f_gap) / f_array > 0.1
            f_0 = f_gap;
        end
    end
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

% onset energy
dot_counts = 0;
ave_energy_ratio = 0;
K = bwlabel(X_inst,8);
t = 1;
while t <= size(X_inst,2)
    if max(X_inst(:,t)) ~= 0
        [mag,f] = max(X_inst(:,t),[],'all');
        label = K(f,t);
        [f_label, t_label] = find(K == label);
        t_0 = min(t_label); t_1 = max(t_label); gap = t_1 - t_0;
        E0 = 0; E1 = 0;
        for t_ = [t_0: t_1]
            if t_ <= t_0 + gap * 0.1
                E0  = E0 + sum(X(:,t_).^2);
            end
            E1 = E1 + sum(X(:,t_).^2);
        end
        dot_counts = dot_counts + gap + 1;
        ave_energy_ratio = ave_energy_ratio + E0/E1 * (gap+1);
        t = t_1;
    end
    t = t+ 1;
end
ave_energy_ratio = ave_energy_ratio/ dot_counts;
output = [c_mean(2:3), ave_residual, E_har, E_all, ave_energy_ratio];
