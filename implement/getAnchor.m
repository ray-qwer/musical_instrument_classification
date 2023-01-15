function anchor = getAnchor(x, fs)
    % assume that the energy of silence part is smooth
    % the variation will not larger than 0.01
    % compare the largest energy with the mean energy at a sequence
    % the length of sequence is 0.1sec, and stride is 0.01 sec
    x = x.^2;
    filter_half_length = (fix(fs/2)/10);
    filter = exp(-0.001.*([-filter_half_length:filter_half_length]./fs).^2);
    x = conv(x,filter,'same');
    x = x.* 0.8/mean(x);
    thr_noisy = mean(x)/1.5;
    thr_silence = 0.05;
    state = false;  % false-> silence, true-> noisy
    anchor = [];
    for i = 1:fs*0.05:length(x)
        if state
            x_seg = x(i:min(length(x), i+fs*0.3-1));
            if (max(x_seg) - mean(x_seg) < thr_silence) && x(i) < mean(x)/5 
                if (isempty(anchor) || i-anchor(end) > fs)  
                    state = ~state;
                    anchor(end+1) = i;
                end
            end
        else
            if x(i) > thr_noisy
                state = ~state;
            end
        end
    end
    if length(anchor) >= 1
        anchor(end) = length(x);
    else
        anchor = [length(x)];
    end
end