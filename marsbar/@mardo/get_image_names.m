function P = get_image_names(D)
% method returning image file names for design
P = '';
if has_images(D)
  VY = get_images(D);
  P = strvcat(VY(:).fname);
end