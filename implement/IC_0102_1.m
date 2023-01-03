% instrument_name = ["piano", "trumpet", "violin", "Ebclarnet", "sopsax"];
addpath('D:\lab\libsvm-3.3\libsvm-3.3\matlab');
load features_5instruments.mat;
label=features_5instruments(:,2);
label =cell2mat(label);
features = features_5instruments(:,1);
features = cell2mat(features);

%% check NaN
[m, ~] = find(isnan(features));
m = unique(m);
features(m,:) = [];
label(m) = [];

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
acc_mat = zeros(5);
for i = 1:length(predicted)
    acc_mat(predicted(i), label_test(i)) = acc_mat(predicted(i),label_test(i))+1; 
end

disp(acc_mat);
disp(mean(accuracy_iter));