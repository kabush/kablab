function [tst_hd,stats] = classify_loocv2(proj,img,labels)

%%
%% Assign default values for optional arguments
%%
pos_cls = proj.param.mvpa.pos_cls;
neg_cls = proj.param.mvpa.neg_cls;
kernel = proj.param.mvpa.kernel;

%% Identify label indices of positive and negative classes
all_pos_ids = find(labels==pos_cls);
all_neg_ids = find(labels==neg_cls);

%% Storage
tst_out = [];
tst_hd = [];
tst_trg = [];
beta = []; 
stats = struct();

all_ids = 1:numel(labels);

for i=1:numel(all_ids)

    tst_id = all_ids(i);
    base_ids = setdiff(all_ids,tst_id);
    
    pos_ids = intersect(all_pos_ids,base_ids);
    neg_ids = intersect(all_neg_ids,base_ids);

    % Balance pos/neg classes in training
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

    %% Train the models
    model = fitcsvm(this_img(this_trn_ids,:),labels(trn_ids),'KernelFunction',kernel);

    %% Test the model
    [tst_predict,tst_score] = predict(model,this_img(this_tst_id,:));
    tst_out = [tst_out;tst_predict];
    tst_hd = [tst_hd;tst_score(2)];
    tst_trg = [tst_trg;labels(tst_id)];
    
    %% Compute statistics
    stats.tst_acc{i} = numel(find(tst_predict-labels(tst_id)==0))/numel(tst_predict);

end