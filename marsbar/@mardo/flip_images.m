function o = flip_images(o)
% flips images in design
%
% $Id$
  
if ~has_images(o), return, end
VY = get_images(o);
M = diag([-1 1 1 1]);
for i = 1:length(VY)
  VY(i).mat = M * VY(i).mat;
end
o = set_images(o, VY);
  