function [map_nii] = build_beta_nii_from_gm_mask(map,gm_mask,gm_ids)

% ***TICKET***: build one function that does both single and beta
% series reformation (should be this one but need to unit test and
% document

%% Generate a nifti file of data from a grey matter mask nifti
Nmaps = size(map,2); %num of maps is the num of beta series

%% Use grey matter mask as a template for storage
%% this is necessary b/c of complex header info
map_nii = gm_mask; 

%% Allocate a zeroed base storage
brain_size = size(gm_mask.img);
full_map = zeros(Nmaps,brain_size(1)*brain_size(2)* ...
                            brain_size(3));

%% Load the svm coefficients into the correct 2-d coordinates
full_map(:,gm_ids)=map';

%% Reform the correct anatomical 3-d structure of the nifti image
tmp_shape = reshape(full_map,Nmaps,brain_size(1),brain_size(2),brain_size(3));
map_nii.img=shiftdim(tmp_shape,1);

%% Add important header information
map_nii.hdr.dime.dim=[4 brain_size Nmaps 1 1 1];
map_nii.hdr.dime.datatype=64;
map_nii.hdr.dime.bitpix=64;
map_nii.original.hdr.dime.dim=[4 brain_size Nmaps 1 1 1];
map_nii.original.hdr.dime.datatype=64;
map_nii.original.hdr.dime.bitpix=64;

%%put in RAI orientation (*** DON'T NEED THIS***)
orient=[4 5 3];
map_nii=rri_orient(map_nii,orient); %silently swear at jimmy shen

end