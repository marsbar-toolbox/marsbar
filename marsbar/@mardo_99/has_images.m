function tf = has_images(o)
% returns 1 if design contains images
tf = isfield(des_struct(o), 'VY');
