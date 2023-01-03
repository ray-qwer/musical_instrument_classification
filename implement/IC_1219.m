% instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax"];
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
correct_num = 0;
load("features_5instruments.mat");
category_num = zeros(1,5);
classify_num = zeros(5,5);
for i = 1:size(files,2)
    correct_ans = features_5instruments{i,2};
    output = features_5instruments{i,1};
    % [1:c1, 2:c2, 3:epsilon, 4:E_b, 5:E_1, 6:E_2, 7:E_A, 8:onset_E]
    c2 = output(2); epsilon = output(3); onset_E = output(8);
    E_0 = output(4); E_A = output(7);
    classify_ans = "";
    if onset_E >= 0.2
        classify_ans = "piano";
    else
        if epsilon > 1.2
            if onset_E > 0.09
                classify_ans = "trumpet";
            else
                classify_ans = "violin";
            end
        else
            if abs(c2)>1E3
                classify_ans = "violin";
            else
                if abs(E_0/E_A - 0.8)/0.8 < 0.5
                    classify_ans = "Ebclarnet";
                else
                    classify_ans = "sopsax";
                end
            end
        end
    end
    cor_index = getIndex(correct_ans);
    cla_index = getIndex(classify_ans);
    category_num(cor_index) = category_num(cor_index) + 1;
    classify_num(cor_index, cla_index) = classify_num(cor_index,cla_index)+1;
    if classify_ans == correct_ans
        correct_num = correct_num+1;
    end
end

disp(correct_num/size(files,2));
classify_num
for i = 1:5
    disp([instrument_name(i),classify_num(i,i)/category_num(i)]);
end
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