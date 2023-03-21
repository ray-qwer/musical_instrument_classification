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
    lower_bound = min(max(X,[],"all")*0.5,40); threshold = lower_bound;  % lower bound need to modify
    stride = 500; slicing_window = 1000; % stride, overlap = 50, slicing window = 100

    X = conv2(X,smoother,'same');
    % get instantaneous frq: local maxima and over threshold 
    % 0203 if with no adaptive threshold?
    threshold = max(lower_bound, max(max(abs(X(30:size_X(1),:))))*0.2);
    for i = [1:l_t]
        % threshold
%         if mod(i,stride) == 1
%             if floor(i/stride) == 0
%                 threshold = max(max(X(:,1:stride)))*0.2;
%             elseif floor(i/stride)+1 >= floor(l_t/stride) 
%                 threshold = max(max(X(:,i-stride:end)))*0.2;
%             else
%                 threshold = max(max(X(:,i-stride:i-stride+slicing_window)))*0.2;
%             end
%             threshold = max(threshold,lower_bound);
%         end

        for j = [61:size_X(1)-1] % 60Hz up
            if X(j,i) > X(j+1,i) && X(j,i) > X(j-1,i) && X(j,i) > threshold
                X_inst(j,i) = 100;
                X_inst(j,i) = 100;
            end
        end
    end
    % lining up 
    [K,num] = bwlabel(X_inst,8);
    signal_table = table('Size',[num,4],'VariableTypes',["double","double","double","double"],'VariableNames',["s_head_x","s_head_y","s_end_x","s_end_y"]);
    for i = [1:num]
        [a,b] = find(K == i);   % a: freq, b: time
        headIndex = find(b == min(b));
        tailIndex = find(b == max(b));
        if length(headIndex) > 1
            headIndex = headIndex(1);
        end
        if length(tailIndex) > 1
            tailIndex = tailIndex(1);
        end
        signal_table(i,:) = {min(b),a(headIndex),max(b),a(tailIndex)};
    end
    signal_table = sortrows(signal_table,[1,2]);
    c1 = 0.2; c2 = 3; dist_threshold = 300; % c1: time dist coefficient, c2: freq dist coefficient
    for i = 1:(num-1)
        s_end = signal_table(i,3:4);
        s_end = table2array(s_end);
        for j = (i+1):num
            s_start = signal_table(j,1:2);
            s_start = table2array(s_start);
            if s_start(1) < s_end(1)
                continue;
            end
            tmp = (c1*(s_end(1)-s_start(1))^2) + (c2*(s_end(2)-s_start(2))^2);
            if tmp < dist_threshold
                % connect!!!
                line_len = max(abs(s_start(1)-s_end(1)),abs(s_start(2)-s_end(2)));
                new_x = round(s_end(1) + [1:line_len]./line_len*(s_start(1)-s_end(1)));
                new_y = round(s_end(2) + [1:line_len]./line_len*(s_start(2)-s_end(2)));
                for n = 1:line_len
                    X_inst(new_y(n),new_x(n)) = 100;
                end
                % update connected region
                % start point
                signal_table(j,1:2) = signal_table(i,1:2);
                signal_table(i,3:4) = signal_table(j,3:4);
                break
            end
        end
    end
    % abandon too short segments 0201
    [K,num] = bwlabel(X_inst, 8);
    len_list = zeros(1,num);
    for i = 1:num
        len_list(i) = numel(find(K == i));
    end
    len_thr = max(max(len_list)*0.3,20);
    short_seg = find(len_list <= len_thr);
    X_inst(ismember(K, short_seg)) = 0;
end