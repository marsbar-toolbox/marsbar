function res = flip_option(obj, data)
% get/set flag for flipping images in design
%
% $Id$
  
if nargin > 1
  obj.flip_option = data;
  res = obj;
else
  res = obj.flip_option;  
end