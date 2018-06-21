function qlty = check_gm_img_qlty(img)

% CHECK_GS_IMG_QLTY: performs various quality checks on GS img
%
%   [qlty] = CHECK_GS_IMG_QLTY(img)
%
%   ARGUMENTS 
%
%   OUPUTS

qlty = struct();
qlty.na = 0;

%% Check for nans in feature space
%% suggests problems in beta series
%% generation with numerous potential
%% sources (registration|warping|etc)
if(isempty(find(isnan(img))))
    qlty.na = 1;
end

%% Generate overall quality flag
qlty.ok = qlty.na;
