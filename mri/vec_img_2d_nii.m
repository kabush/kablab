function [image] = vec_img_2d_nii(raw_image)

[x,y,z,t] = size(raw_image.img);
image = reshape(raw_image.img,[x*y*z,t]);

end

