function anchor = segment_anchor(x,fs)
    % threshold setting
    x = x.^2;
    filter = exp(-0.001.*([-2200:2200]./fs).^2);
    x = conv(x,filter,"same");
    x = x * 0.8/max(x(x<max(x)/2));
    thr_silence = 0.8/100;
%     thr_silence = 0;
    thr_noisy = mean(abs(x));
%     thr_noisy = max(abs(x))/10;
    state_count_thr = 0.5*fs;
    
    % variables
    state = false;
    state_count = 0;
    anchor = [];
    for i = 1:length(x)
        if ~state
            if abs(x(i)) >= thr_noisy
                state = ~state;
                state_count = 0;
            end
        else
            if abs(x(i)) <= thr_silence
                state_count = state_count +1;
            else
                state_count = 0;
            end
        end
        if state_count >= state_count_thr
            if state && (isempty(anchor) || i-anchor(end) > fs)  
                anchor(end+1) = i-state_count_thr-30;
            end
            state = ~state;
            state_count = 0;
        end
    end
    if length(anchor) >= 1
        anchor(end) = length(x);
    else
        anchor = [length(x)];
    end
end

