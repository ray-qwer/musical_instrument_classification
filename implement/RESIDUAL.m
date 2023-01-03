% return all residuals by an array
% input: a: time series
%        b: frequency series
%        C_array: coefficient of appropriate 
function residual = RESIDUAL(a, b, C_array, dtau)
    a = a - min(a);
    power = 0;
    partial = zeros(size(a));
    for c = 1:length(C_array)
        if isnan(C_array(c))
            continue;
        end
        partial = partial + C_array(c).*((a.*dtau).^power);
        power = power + 1;
    end
    residual = b - partial;
end