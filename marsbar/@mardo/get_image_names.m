function P = get_image_names(D)
% method returning image file names for design
% Returns cell array of same dimension of image list
P = '';
if has_images(D)
  VY = get_images(D);
  P = reshape({VY.fname},size(VY));
end