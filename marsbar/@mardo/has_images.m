function tf = has_images(o)
% returns 1 if design contains images
tf = isfield(o.des_struct, 'VY');