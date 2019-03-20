function [tst_out,tst_trg,tst_hd,mdl,stats] = regress_intra_loocv(img,scores,kernel)
% REGRESS_INTRA_LOOCV conducts cross-validation using svm via the specified kernel
%
%   [...] = REGRESS_INTRA_LOOCV(img,scores,kernel)
%
%   ARGUMENTS 
%
%   OUPUTS

%% Identify labels belonging to this subject
tst_ids = 1:numel(scores);

%% Find voxels with nonzero beta values
mu = mean(abs(img),1);
nonzero_ids = find(mu>0);

%% Allocate storage
tst_out = [];
tst_hd = [];
tst_trg = [];
betas = [];
stats = struct();
mdl = struct();

%% Execute if there are features available
if(numel(nonzero_ids)>0)

    %% ----------------------------------------
    %% This is intra-subject LOOCV    
    %% ----------------------------------------
    %% for i=1:numel(tst_ids)
    parfor i=1:numel(tst_ids)
        
    %     if mod(i,10)==0
    %         i
    %     end


        %%Get the test id
        tst_id = tst_ids(i);
        
        %%Get all non test ids
        trn_ids = setdiff(tst_ids,tst_id);
        
        %% train the model
        mdl = fitrsvm(img(trn_ids,nonzero_ids),scores(trn_ids),'KernelFunction',kernel);
        
        %% test the model
        [tst_predict] = predict(mdl,img(tst_id,nonzero_ids));
        tst_out = [tst_out;tst_predict];
        tst_trg = [tst_trg;scores(tst_id)];
        
        %% Store data
        betas = [betas;mdl.Beta'];
        
    end
    
end

%% Compute statistics
[rho p] = corr(tst_out,tst_trg);
stats.rho = rho;
stats.rho_p = p;

[b stat] = robustfit(tst_out,tst_trg);
stats.b = b(2);
stats.b_p = stat.p(2);
    
%% Compute mean over all CV models
mdl.betas = mean(betas,1);
mdl.ids = nonzero_ids;