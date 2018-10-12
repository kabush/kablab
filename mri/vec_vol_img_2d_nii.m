function [image] = vec_vol_img_2d_nii(raw_image,vol)

[x,y,z,t] = size(raw_image.img(:,:,:,vol));
image = reshape(raw_image.img(:,:,:,vol),[x*y*z,t]);

end

