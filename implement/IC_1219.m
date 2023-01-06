
% files = string(zeros(2,0));
% % get all files
% for i = 1:length(instrument_name)
%     [lists, loc] = getInstrumentFile(instrument_name(i), "..\music_samples");
%     if instrument_name(i) == "violin"
%         [lists, loc] = getInstrumentFile("arco",loc);
%     end
%     l = string(zeros(2, length(lists)));
%     for j = 1:length(lists)
%         l(:,j) = [loc+"\"+lists(j).name, instrument_name(i)];
%     end
%     files = cat(2, files, l);
% end


% rules
% piano: onset > 0.2
% clarnet: onset round 0.08 and E0/EA round 0.8
% trumpet: epsilon > 1 and onset 0.09 up and E1/EA round 0.38
% sopsax: E0/EA round 0.09
% violin: others
% random tree??
%%
correct_num = 0;
load("features_5instruments.mat");
label=features_5instruments(:,2);
label =cell2mat(label);
features = features_5instruments(:,1);
features = cell2mat(features);
[m, ~] = find(isnan(features));
m = unique(m);
features(m,:) = [];
label(m) = [];

sample_num = length(label);
shuffle = randperm(sample_num);
label = label(shuffle);
features = features(shuffle,:);
K = 10;
test_num = round(sample_num/K);
label = label(end-test_num+1:end);
features = features(end-test_num:end,:);

%%
instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax"];
%                       1,      2,          3,      4,              5
category_num = zeros(1,5);
classify_num = zeros(5,5);
for i = 1:size(label,1)
    correct_ans = label(i);
    output = features(i,:);
    % output: [c1, c2, residual(epsilon), E0/EA, E1/EA, E2/EA, E1/E0, E2/E0, E2/E1, onset_energy]
    %           1, 2,   3,                  4,   5,     6,      7,      8,      9,       10,
    c2 = output(2); epsilon = output(3); onset_E = output(10);
    E0EA = output(9);
    classify_ans = "";
    if onset_E >= 0.2
        classify_ans = 1;
    else
        if epsilon > 1.2
            if onset_E > 0.09
                classify_ans = 2;
            else
                classify_ans = 3;
            end
        else
            if abs(c2)>1E3
                classify_ans = 3;
            else
                if abs(E0EA - 0.8)/0.8 < 0.5
                    classify_ans = 4;
                else
                    classify_ans = 5;
                end
            end
        end
    end
%     cor_index = getIndex(correct_ans);
%     cla_index = getIndex(classify_ans);
    category_num(correct_ans) = category_num(correct_ans) + 1;
    classify_num(correct_ans, classify_ans) = classify_num(correct_ans, classify_ans)+1;
    if classify_ans == correct_ans
        correct_num = correct_num+1;
    end
end

% disp(correct_num/size(label,1));
classify_num
for i = 1:5
    disp([instrument_name(i),classify_num(i,i)/category_num(i)]);
end
disp(["correct rate",correct_num/size(label,1)]);
function index = getIndex(name)
    % order: "piano", "trumpet", "violin", "Ebclarnet", "sopsax"
    instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax"];
    for i = 1:length(instrument_name)
        if name == instrument_name(i)
            index = i;
            return;
        end
    end
end