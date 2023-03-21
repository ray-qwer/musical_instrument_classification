clc; clear;
%% categories name
instru_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax","tuba","horn","bassTrombone",...
    "cello","viola","doubleBass","altosax","bassflute","bassoon","Bbclarnet","flute","oboe"];
string_instrument = ["violin","viola","doubleBass","cello"];
brass_instrument = ["trumpet","tuba","horn","bassTrombone"];
woodwind_instrument = ["Ebclarnet","sopsax","altosax","bassflute","bassoon","Bbclarnet","flute","oboe"];
percussion_instrument = ["piano"];
instrument_name = [percussion_instrument, string_instrument, brass_instrument, woodwind_instrument];
%% initial
addpath('D:\lab\libsvm-3.3\libsvm-3.3\matlab');
% load features
load features_17instruments_0203.mat
features_dataset = features_17instruments_0203;
label=features_dataset(:,2);
label =cell2mat(label);
features = features_dataset(:,1);
features = cell2mat(features);
% features = features(:,1:end);
sources = string(features_dataset(:,3));
%% check undefined samples
silence_s = find(contains(sources,"silence") == 1);
features(silence_s,:) = [];
label(silence_s) = [];
[m, ~] = find(isnan(features));
m = unique(m);
features(m,:) = [];
label(m) = [];
category_num = unique(label);

%% new label

% label_n = zeros(size(label));
% for i = 1:length(instru_name)
%     label_n(label == i) = find(instrument_name == instru_name(i));
% end
% label = label_n;
%%
string_ins_label = zeros(1,length(string_instrument));
brass_ins_label = zeros(1,length(brass_instrument));
woodwind_ins_label = zeros(1,length(woodwind_instrument));
percussion_ins_label = zeros(1,length(percussion_instrument));

for i = 1:length(string_ins_label)
    string_ins_label(i) = find(instrument_name == string_instrument(i));
end
for i = 1:length(brass_ins_label)
    brass_ins_label(i) = find(instrument_name == brass_instrument(i));
end
for i = 1:length(woodwind_ins_label)
    woodwind_ins_label(i) = find(instrument_name == woodwind_instrument(i));
end
for i = 1:length(percussion_ins_label)
    percussion_ins_label(i) = find(instrument_name == percussion_instrument(i));
end

family = [1:4]; % 1: woodwind, 2: brass, 3: string, 4: percussion

%% add family name
label_family = zeros(length(label),1);
label_family(ismember(label, percussion_ins_label)) = 1;
label_family(ismember(label, brass_ins_label)) = 2;
label_family(ismember(label, string_ins_label)) = 3;
label_family(ismember(label, woodwind_ins_label)) = 4;

%% shuffle
sample_num = length(label);
shuffle = randperm(sample_num);
label = label(shuffle);
features = features(shuffle,:);
label_family = label_family(shuffle);

%% init model
model1 = nan;
model2 = [];
%% training first level model with K fold, K = 10;
K = 10;
test_num = fix(sample_num/K);
train_num = sample_num - test_num;

for i = 1:K
    disp(['Processing ',num2str(i),' Fold']);
    label_test = label_family((i-1)*test_num+1:i*test_num);
    features_test = features((i-1)*test_num+1:i*test_num,:);
    label_train = cat(1,label_family(1:(i-1)*test_num+1), label_family(i*test_num+1:end));
    features_train = cat(1,features(1:(i-1)*test_num+1,:), features(i*test_num+1:end,:));
    
    m_train = size(features_train,1);
    m_test = size(features_test,1);
    m_mean_1 = mean(features_train);
    nrm_1 = diag(1./std(features_train,1));
    features_train_scaling = (features_train-m_mean_1)*nrm_1;
    features_test_scaling = (features_test - m_mean_1)*nrm_1;
    
    model1 = svmtrain(label_train, features_train_scaling);
    
    % test 
    [predicted, accuracy, d_values] = svmpredict(label_test, features_test_scaling, model1);
    
end




%% training second model with K fold, K =5
K = 5;
acc_family = zeros(1,4);
mean2_set = zeros(4,size(features,2));
nrm_set = zeros([4,size(features,2),size(features,2)]);
for j = 1:4
    label_set_j = label(label_family == j);
    features_set_j = features(label_family == j,:);
    test_num = fix(length(label_set_j)/K);
    for i = 1:K
        disp(['Processing: ','family:',num2str(j),',',num2str(i),' Fold',]);
        label_test = label_set_j((i-1)*test_num+1:i*test_num);
        features_test = features_set_j((i-1)*test_num+1:i*test_num,:);
        label_train = cat(1,label_set_j(1:(i-1)*test_num+1), label_set_j(i*test_num+1:end));
        features_train = cat(1,features_set_j(1:(i-1)*test_num+1,:), features_set_j(i*test_num+1:end,:));
        
        m_train = size(features_train,1);
        m_test = size(features_test,1);
        m_mean = mean(features_train);
        nrm = diag(1./std(features_train,1));
        features_train_scaling = (features_train-m_mean)*nrm;
        features_test_scaling = (features_test - m_mean)*nrm;
        
        model = svmtrain(label_train, features_train_scaling);
        
        % test 
        [predicted, accuracy, d_values] = svmpredict(label_test, features_test_scaling, model);
        if i == K
            acc_family(j) = accuracy(1);
            mean2_set(j,:) = m_mean;
            nrm_set(j,:,:) = nrm;
            model2 = [model2, model];
        end
    end
end

%% testing
acc_cat_mat = zeros(length(category_num));
acc_fam_mat = zeros(4);
test_num = fix(sample_num/K);
correction = zeros(1,10);
for i = 1:length(correction)
    shuffle = randperm(sample_num);
    label = label(shuffle); features= features(shuffle,:); label_family = label_family(shuffle);
    % layer 1
    label_test = label(end-test_num+1:end); features_test = features(end-test_num+1:end,:);
    label_family_test = label_family(end-test_num+1:end);
    features_test_scaling = (features_test - m_mean_1)*nrm_1;
    [predicted, accuracy, d_values] = svmpredict(label_family_test, features_test_scaling, model1);
    % layer 2
    for j = 1:4
        model = model2(j);
        layer2_idx = find(predicted==j); % the jth family
        layer2_label_test = label_test(layer2_idx);
        layer2_features_test_scaling = (features_test(layer2_idx,:)-mean2_set(j,:))*squeeze(nrm_set(j,:,:));
        [p, acc, d] = svmpredict(layer2_label_test,layer2_features_test_scaling,model);
        for k = 1:length(p)
            acc_cat_mat(p(k), layer2_label_test(k)) = acc_cat_mat(p(k),layer2_label_test(k))+1;
        end
        
        correction(i) = correction(i)+acc(1)*length(p);
    end
    correction(i) = correction(i)/length(predicted);
    for j = 1:length(predicted)
        acc_fam_mat(predicted(j), label_family_test(j)) = acc_fam_mat(predicted(j),label_family_test(j))+1; 
    end
end
disp(acc_cat_mat);
disp(mean(correction));
acc_cat = zeros(1,size(acc_cat_mat,1));
for i = 1:size(acc_cat_mat,1)
    total_tmp = sum(acc_cat_mat(i,:));
    disp([num2str(i),' correction: ',num2str(acc_cat_mat(i,i)/total_tmp)]);
    acc_cat(i) = acc_cat_mat(i,i)/total_tmp;
end
disp(acc_fam_mat);