function anchor = getAnchor(x, fs)
    % assume that the energy of silence part is smooth
    % the variation will not larger than 0.01
    % compare the largest energy with the mean energy at a sequence
    % the length of sequence is 0.1sec, and stride is 0.01 sec
    x = x.^2;
    filter_half_length = (fix(fs/2)/10);
    filter = exp(-0.001.*([-filter_half_length:filter_half_length]./fs).^2);
    x = conv(x,filter,'same');
    m = max(mean(x)*4,max(x)/30);
    x(x> m) = m;
    x = x.* 0.8/max(x);
    thr_noisy = 0.03;
    thr_silence = 0.01;
    state = false;  % false-> silence, true-> noisy
    anchor = [];
    for i = 1:fix(fs*0.05):length(x)
        
        if state
            x_seg_silence = x(i:min(length(x), i+fix(fs*0.005)-1)); % brass: 0.005, others: 0.2
            if (var(x_seg_silence) < 0.0005) && x(i) < thr_silence 
                if (isempty(anchor)) ||i-anchor(end) > 2*fs
                    state = false;
                    anchor(end+1) = i;

                end
            end
        else
            x_seg_noisy = x(i:min(length(x), i+fix(fs*0.6)-1)); 
            if all(x_seg_noisy > thr_noisy) 
                state = true;
            end
        end
    end
    if length(anchor) >= 1
        anchor(end) = length(x);
    else
        anchor = [length(x)];
    end
end