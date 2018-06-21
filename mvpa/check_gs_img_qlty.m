function qlty = check_gs_img_qlty(img)

% CHECK_GS_IMG_QLTY: performs various quality checks on GS img
%
%   [qlty] = CHECK_GS_IMG_QLTY(img)
%
%   ARGUMENTS 
%
%   OUPUTS

qlty = struct();
qlty.dim = 0;
qlty.na = 0;

%% Check that feature dim = stim dim
%% if feat dim < stim dim then data
%% likely has serious problems
[m n]= size(img);
if(m==n)
    qlty.dim = 1;
end

%% Check for nans in feature space
%% suggests problems in beta series
%% generation with numerous potential
%% sources (registration|warping|etc)
if(isempty(find(isnan(img))))
    qlty.na = 1;
end

%% Generate overall quality flag
qlty.ok = qlty.dim*qlty.na;
