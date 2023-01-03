% usage: input: x:  one-side sound
%               fs: sampling frequency
%               f_max: the maximum frequency of stft
%        output: X: the result of stft, array
%                t: time index of stft
%                f: frequency index of stft
% this function is used for transforming a signal into time-frequency
% domain.
% origin one QQ
% function [X, t, f] = STFT(x, fs, f_max)
%     time = [0:size(x,1)-1]/fs;
%     if size(x,2) < size(x,1)
%         x = x.';
%     end
%     dt = 1/fs; df = 1;  dtau = 0.005; shift = dtau/dt; N = 1/(dt*df);
%     if f_max > floor(N/2)
%         warning("f_max is bigger than expected.");
%         f_max = floor(N/2);
%     end
%     f = [0:df:f_max];    t = [0:dtau:max(time)];
%     sigma=200;  Q=round(1.9143/sqrt(sigma)/dt);
%     period = [-Q:Q]*dt;
%     windows = exp(-pi*sigma*(period).^2);
% 
%     time_count = 1;
%     X = zeros(length(f),length(t));
%     for ind_ideal = [1:shift:size(x,2)]
%         index = floor(ind_ideal);
%         signal = zeros(1,2*Q+1);
%         % padding
%         start_i = index-Q;  end_i = index + Q;
%         if end_i > length(x)
%             end_i = length(x);
%         end
%         if start_i < 1
%             signal(-start_i+2:end) = x(1:end_i);
%         else
%             signal(1:end_i-start_i+1) = x(start_i:end_i);
%         end
%         signal = signal .* windows;
%         freq = abs(fft(signal,N));
%         freq = freq(1:floor(f(end))+1);
%         freq(2:end-1) = 2.*freq(2:end-1);
%         X(:,time_count) = freq.';
%         time_count = time_count+1;
%     end
%     X(1,:) = zeros(1,length(t));
% end
function [X, t, f] = STFT(x, fs, f_max)
    if size(x,1) >size(x,2)
        x = x.';
    end
    if size(x,1) >1
        x = x(1,:);
    end
    df = 1; dt = 1/fs; dtau = 0.005; S = dtau/dt;
    sgm = 200; B = 1.9143/(sqrt(sgm)); Q = fix(B/dt); N = fix(1/(dt*df));
    f = [0:df:f_max];    t = [0:dtau:(size(x,2)-1)/fs];
    c0 = fix(min(t)/ dt); m0 = fix(min(f)/ df);
    F = ((max(f)- min(f))/ df)+1; C = ((max(t)- min(t))/ dtau)+1;
    window = exp(-sgm* pi* dt^2 .* [-Q:Q].^2); % 2Q+1 pnts
    X = zeros([F,C]);
    x = [zeros(1,Q),x,zeros(1,Q)];
    for n = c0: c0+ C- 1
        x_f = x((n*S+1):(n*S+2*Q+1));   % 2Q+1 pnts
        X_f = abs(fft(x_f .* window, N));
        X(:,n-c0+1) = 2.*X_f(m0+1:m0+F)';
    end
    X(1,:) = zeros(1,length(C));
end