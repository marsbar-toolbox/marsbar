function tf = has_images(o)
% returns 1 if design contains images
% 
% $Id$
  
tf = isfield(des_struct(o), 'VY');
