function [tst_out,tst_trg,tst_hd,betas,stats] = classify_loocv(img,labels,subj_labels,subj,kernel)
% CLASSIFY_CV conducts cross-validation using svm via the specified kernel
%
%   [trn_fold, tst_fold, ...] = CLASSIFY_LOOCV(data,trn_fold,tst_fold,kernel)
%
%   ARGUMENTS 
%
%   OUPUTS

%%
%% Assign default values for optional arguments
%%
pos_cls = [1];
neg_cls = [-1];

%% Identify label indices of positive and negative classes
%% Code allows for arrays of positive classes to be assigned
all_pos_ids = [];
for i=1:numel(pos_cls)
    all_pos_ids = [all_pos_ids;find(labels==pos_cls(i))];
end

all_neg_ids = [];
for i=1:numel(neg_cls)
    all_neg_ids = [all_neg_ids;find(labels==neg_cls(i))];
end

%% Identify labels belonging to this subject
tst_ids = find(subj_labels==subj);

tst_out = [];
tst_hd = [];
tst_trg = [];
betas = [];%zeros(numel(labels),size(img,2));

for i=1:numel(tst_ids)
    
    %%Get the test id
    tst_id = tst_ids(i);
    
    %%Get all non test ids
    base_ids = setdiff(tst_ids,tst_id);
    
    %% Identify the intersection of this subject's id's with
    %% the positive and negative distinctions
    pos_ids = intersect(all_pos_ids,base_ids);
    neg_ids = intersect(all_neg_ids,base_ids);
    

    %% Balance positive and negative examples
    Npos = numel(pos_ids);
    Nneg = numel(neg_ids);

    if(Npos >= Nneg)
        Nsample = Nneg;
    else
        Nsample = Npos;
    end

    pos_perm = randperm(numel(pos_ids));
    neg_perm = randperm(numel(neg_ids));
    
    rnd_pos_ids = pos_ids(pos_perm(1:Nsample));
    rnd_neg_ids = neg_ids(neg_perm(1:Nsample));

    %% Assembled full training ideas
    trn_ids = [rnd_pos_ids',rnd_neg_ids'];

    %% Find voxels with nonzero beta values
    mu = mean(abs(img),1);
    rdx_dim = find(mu>0);

    %% Z-score the combined trn_ids/tst_id
    this_img = zscore(img([trn_ids,tst_id],rdx_dim));
    this_trn_ids = 1:numel(trn_ids);
    this_tst_id = numel(trn_ids)+1;

    %% train the models
    model = fitcsvm(this_img(this_trn_ids,:),labels(trn_ids),'KernelFunction',kernel);

    %% test the model
    [tst_predict,tst_score] = predict(model,this_img(this_tst_id,:));
    tst_out = [tst_out;tst_predict];
    tst_hd = [tst_hd;tst_score(2)];
    tst_trg = [tst_trg;labels(tst_id)];

    %% Compute statistics
    stats.tst_acc{i} = numel(find(tst_predict-labels(tst_id)==0))/numel(tst_predict);
    
    %% Save the SVM betas
    betas = [betas; model.Beta'];

end





