function anchor = segment_anchor(x)
    % threshold setting
    thr_silence = 0;
    thr_noisy = 0.03;
    state_count_thr = 10;
    
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
            if state
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

