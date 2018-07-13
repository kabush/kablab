function [tst_out,tst_trg,tst_hd,betas,stats] = regress_inter_loocv(img,scores,subj_labels,subj,kernel)
% REGRESS_INTER_LOOCV conducts cross-validation using svm via the specified kernel
%
%   [...] = REGRESS_INTER_LOOCV(img,scores,subj_labels,subj,kernel)
%
%   ARGUMENTS 
%
%   OUPUTS

%% Identify labels belonging to this subject
tst_ids = find(subj_labels==subj);

%% Find voxels with nonzero beta values
mu = mean(abs(img),1);
nonzero_ids = find(mu>0);

%% Allocate storage
tst_out = [];
tst_hd = [];
tst_trg = [];
betas = [];
stats = struct();

%% Execute if there are features available
if(numel(nonzero_ids)>0)

    %% This is inter-subject LOOCV
    trn_ids = setdiff(1:numel(subj_labels),tst_ids);
    
    %% train the model
    mdl = fitrsvm(img(trn_ids,nonzero_ids),scores(trn_ids),'KernelFunction',kernel);
    
    %% test the model
    [tst_predict] = predict(mdl,img(tst_ids,nonzero_ids));
    tst_out = [tst_out;tst_predict];
    tst_trg = [tst_trg;scores(tst_ids)];
    
    %% Compute statistics
    [rho p] = corr(tst_out,tst_trg);
    stats.p = p;
    stats.rho = rho;

    %% Store data
    betas = [betas;mdl.Beta'];
    
end

