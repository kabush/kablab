function [prime_dsgn,other_dsgn] = scr_dsgn_preproc(proj,n_tr,stim_times)
% scr_dsgn_preproc constructs an scr design representation based on
% the stimulation times.  The formed design functions are compatible
% with either LSA or LSS variants (Mumford et al., 2012)of the beta
% series method.  The prime design can be used directly to conduct
% LSA.  Combining prime with other (row-wise) in individual
% regressions will allow the LSS variant.  The formed design functions
% are also filtered identically to the methodology of scr data.  The
% SCR function used to build the design is based on the scralyze
% toolbox of Bach et al., 2013)
%
%  [prime_dsgn, other_dsng] = scr_preproce(proj,n_tr,stim_times)
%
%  ARGUMENTS
%    proj = project structure
%    n_tr = the length of the file that is aligned with the fMRI
%    stim_times = raw stimulus times of the paradigm
%
%  OUTPUTS
%    prime_dsgn = a matrix in which each row is the design of a
%                 single stimulus
%    other_dsgn = a matrix in which each row is the design of all
%                 stimuli not in the prime matrix (for LSS)
% %
%  REFERENCES
%    Bach et al, 2009
%    Mumford et al., 2012
%    Bach et al, 2013
%    Staib et al., 2015

n_hirez = proj.param.betas.hirez;
TR = proj.param.mri.TR;

%% Build hi-resolution kernel (scralyze toolbox)
kernel = scr_bf_crf(TR/n_hirez);

%% Adjust times to hirez
hirez_stim_times = round(stim_times*n_hirez);

%% Assign stimulus encodings and convovle SCR design
prime_scr_encoding = zeros(numel(stim_times),TR*n_tr*n_hirez);
prime_scr= 0*prime_scr_encoding;
prime_scr_fltr = 0*prime_scr;

%% Assign stimulus encodings and convovle SCR design
other_scr_encoding = zeros(numel(stim_times),TR*n_tr*n_hirez);
other_scr= 0*other_scr_encoding;
other_scr_fltr = 0*other_scr;

for i=1:numel(stim_times)
    
    %%build primary hirez design
    prime_id = hirez_stim_times(i);
    scr_ids = prime_id : (prime_id + TR*n_hirez-1);
    prime_scr_encoding(i,scr_ids) = 1;
    prime_scr(i,:) = convolve_scr(prime_scr_encoding(i,:),kernel);

    %%build secondary hirez design
    other_ids = setdiff(1:numel(stim_times),i);
    scr_ids = [];
    for j=1:numel(other_ids)
        other_id = other_ids(j);
        diff_id = hirez_stim_times(other_id);
        scr_ids = [scr_ids,diff_id : (diff_id + TR*n_hirez-1)];
    end
    other_scr_encoding(i,scr_ids) = 1;
    other_scr(i,:) = convolve_scr(other_scr_encoding(i,:),kernel);

    %%filter design
    half_samp=n_hirez/2;
    high = proj.param.physio.filt_scr_high;
    low = proj.param.physio.filt_scr_low;
    [B A] = butter(1,[high/half_samp low/half_samp]);
    
    %%apply filter
    if(proj.param.physio.filt_scr_type==1)
        %unidirectional
        prime_scr_fltr(i,:) = filter(B,A,prime_scr(i,:));
        other_scr_fltr(i,:) = filter(B,A,other_scr(i,:));
    else
        %bidirectional
        prime_scr_fltr(i,:) = filtfilt(B,A,prime_scr(i,:));
        other_scr_fltr(i,:) = filtfilt(B,A,other_scr(i,:));
    end

end

%% generate low-resolution filtered SCR
for i=1:size(prime_scr,1)
    prime_dsgn(i,:) = zscore(mean(reshape(prime_scr_fltr(i,:),TR*n_hirez,n_tr)));
    other_dsgn(i,:) = zscore(mean(reshape(other_scr_fltr(i,:),TR*n_hirez,n_tr)));
end
