% usage:
% input: X: the result of STFT, time-frequency domain array
% t: time_index


function X_inst = INST_FREQ(X)
    X = abs(X);
    X_inst = zeros(size(X));
    size_X = size(X_inst);
    l_t = size(X_inst, 2);
    % variables
    sca = 20; lambda = 10; smoother_p = [-lambda:lambda].'; 
    smoother = exp(-(smoother_p./sca).^2);
    lower_bound = 50; threshold = lower_bound;
    stride = 50; slicing_window = 100; % stride, overlap = 50, slicing window = 100

    X = conv2(X,smoother,'same');
    % get instantaneous frq
    for i = [1:l_t]
        % threshold
        if mod(i,stride) == 1
            if floor(i/stride) == 0
                threshold = max(max(X(:,1:stride)))*0.2;
            elseif floor(i/stride)+1 >= floor(l_t/stride) 
                threshold = max(max(X(:,i-stride:end)))*0.2;
            else
                threshold = max(max(X(:,i-stride:i-stride+slicing_window)))*0.2;
            end
            threshold = max(threshold,lower_bound);
        end

        for j = [61:size_X(1)-1]
            if X(j,i) > X(j+1,i) && X(j,i) > X(j-1,i) && X(j,i) > threshold
                X_inst(j,i) = 100;
                X_inst(j,i) = 100;
            end
        end
    end
    % lining up 
    [K,num] = bwlabel(X_inst);
    signal_table = table('Size',[num,4],'VariableTypes',["double","double","double","double"],'VariableNames',["s_head_x","s_head_y","s_end_x","s_end_y"]);
    for i = [1:num]
        [a,b] = find(K == i);
        headIndex = find(a == min(a));
        tailIndex = find(a == max(a));
        if length(headIndex) > 1
            headIndex = headIndex(1);
        end
        if length(tailIndex) > 1
            tailIndex = tailIndex(1);
        end
        signal_table(1,:) = {min(a),b(headIndex),max(a),b(tailIndex)};
    end
    signal_table = sortrows(signal_table,[1,2]);
    c1 = 1; c2 = 0.8; dist_threshold = 1000;
    for i = 1:(num-1)
        s_end = signal_table(i,3:4);
        s_end = table2array(s_end);
        for j = (i+1):num
            s_start = signal_table(j,1:2);
            s_start = table2array(s_start);
            if s_start(1) < s_end(1)
                continue;
            end
            tmp = (c1*(s_end(1)-s_start(1)))^2 + (c2*(s_end(2)-s_start(2)))^2;
            if tmp < dist_threshold
                % connect!!!
                line_len = max(abs(s_start(1)-s_end(1)),abs(s_start(2)-s_end(2)));
                for n = 1:line_len
                    new_x = round(s_end(1) + n/line_len*(s_start(1)-s_end(1)));
                    new_y = round(s_end(2) + n/line_len*(s_start(2)-s_end(2)));
                    X_inst(new_x,new_y) = 100;
                end
                % update connected region
                % start point
                signal_table(j,1:2) = signal_table(i,1:2);
                signal_table(i,3:4) = signal_table(j,3:4);
                break
            end
        end
    end
end