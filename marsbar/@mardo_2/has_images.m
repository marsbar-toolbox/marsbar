function tf = has_images(o)
% returns 1 if design contains images
% 
% $Id$

tf = 0;
des = des_struct(o);
if isfield(des, 'xY')
  tf = isfield(des.xY, 'VY');
end
