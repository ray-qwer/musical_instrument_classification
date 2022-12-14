% instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax"];
addpath('D:\lab\libsvm-3.3\libsvm-3.3\matlab');
% addpath('D:\NTUEE\master_1\lab\musical_instrument_classification\musical_instrument_classification_git\musical_instrument_classification\libsvm_matlab');
load features_5instruments_0110.mat;
% output = [c_mean(2:3), ave_residual,E_feature, ave_energy_ratio(10:10:100), E_stable(1:3)];
features_dataset = features_5instruments_0110;
label=features_dataset(:,2);
label =cell2mat(label);
features = features_dataset(:,1);
features = cell2mat(features);
features = features(:,1:end);

%% check NaN
[m, ~] = find(isnan(features));
m = unique(m);
features(m,:) = [];
label(m) = [];
% four categories
% label(label == 5) = 4;
category_num = unique(label);
%% shuffle
sample_num = length(label);
shuffle = randperm(sample_num);
label = label(shuffle);
features = features(shuffle,:);

% %% take 1/10 as test data
% test_num = round(sample_num/10);
% train_num = sample_num - test_num;
% label_train = label(1:train_num);
% label_test = label(train_num+1:end);
% features_train = features(1:train_num,:);
% features_test = features(train_num+1:end,:);
% 
% %% scaling
% m_train = size(features_train,1);
% m_test = size(features_test,1);
% m_mean = mean(features_train);
% nrm = diag(1./std(features_train,1));
% features_train_scaling = (features_train-m_mean)*nrm;
% features_test_scaling = (features_test - m_mean)*nrm;
% 
% %% SVM
% model = svmtrain(label_train, features_train_scaling);
% 
% % test 
% [predicted, accuracy, d_values] = svmpredict(label_test, features_test_scaling, model);
%% K Fold
K = 10;
test_num = round(sample_num/K);
train_num = sample_num - test_num;
model = nan;
accuracy_iter = zeros(1,K);
for i = 1:K
    disp(['Processing ',num2str(i),' Fold']);
    label_test = label((i-1)*test_num+1:i*test_num);
    features_test = features((i-1)*test_num+1:i*test_num,:);
    label_train = cat(1,label(1:(i-1)*test_num+1), label(i*test_num+1:end));
    features_train = cat(1,features(1:(i-1)*test_num+1,:), features(i*test_num+1:end,:));
    
    m_train = size(features_train,1);
    m_test = size(features_test,1);
    m_mean = mean(features_train);
    nrm = diag(1./std(features_train,1));
    features_train_scaling = (features_train-m_mean)*nrm;
    features_test_scaling = (features_test - m_mean)*nrm;
    
     model = svmtrain(label_train, features_train_scaling);
    
    % test 
    [predicted, accuracy, d_values] = svmpredict(label_test, features_test_scaling, model);
    accuracy_iter(i) = accuracy(1);
end

%% accuracy per categories
acc_mat = zeros(length(category_num));

correction = zeros(1,10);
for i = 1:length(correction)
    shuffle = randperm(sample_num);
    label = label(shuffle); features= features(shuffle,:);
    label_test = label(end-test_num+1:end); features_test = features(end-test_num+1:end,:);
    features_test_scaling = (features_test - m_mean)*nrm;
    [predicted, accuracy, d_values] = svmpredict(label_test, features_test_scaling, model);
    correction(i) = accuracy(1);
    for j = 1:length(predicted)
        acc_mat(predicted(j), label_test(j)) = acc_mat(predicted(j),label_test(j))+1; 
    end
end
disp(acc_mat);
disp(mean(correction));
for i = 1:size(acc_mat,1)
    total_tmp = sum(acc_mat(i,:));
    disp([num2str(i),' correction: ',num2str(acc_mat(i,i)/total_tmp)]);
end