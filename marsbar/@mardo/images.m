function r = images(o, imgs)
% method to get or set images 
% 
% $Id$
  
if nargin < 2
  r = get_images(o);
else
  r = set_images(o, imgs);
end