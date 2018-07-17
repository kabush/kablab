function [tst_out,tst_trg,tst_hd,model] = regress_inter_loocv(img,scores,subj_labels,subj,kernel)
% REGRESS_INTER_LOOCV conducts cross-validation using svm via the specified kernel
%
%   [...] = REGRESS_INTER_LOOCV(img,scores,subj_labels,subj,kernel)
%
%   ARGUMENTS 
%
%   OUPUTS


%% Allocate storage
tst_out = [];
tst_hd = [];
tst_trg = [];

%% Internal structure
model = struct();
model.betas = [];
model.stats = [];

%% Find voxels with nonzero beta values
mu = mean(abs(img),1);
model.ids = find(mu>0);

%% Identify labels belonging to this subject
tst_ids = find(subj_labels==subj);

%% Execute if there are features available
if(numel(model.ids)>0)

    %% This is inter-subject LOOCV
    trn_ids = setdiff(1:numel(subj_labels),tst_ids);
    
    %% train the model
    mdl = fitrsvm(img(trn_ids,model.ids),scores(trn_ids),'KernelFunction',kernel);
    
    %% test the model
    [tst_predict] = predict(mdl,img(tst_ids,model.ids));
    tst_out = [tst_out;tst_predict];
    tst_trg = [tst_trg;scores(tst_ids)];
    
    %% Compute statistics
    [rho p] = corr(tst_out,tst_trg);
    model.stats.p = p;
    model.stats.rho = rho;

    %% Store data
    model.betas = [model.betas;mdl.Beta'];
    
end

