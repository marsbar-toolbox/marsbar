function h = roithresh(obj, val)
% roithresh - returns / sets roithresh value for object
%
% $Id$

if nargin > 1
  if val < 0 | val > 1
    error('Value must be between 0 and 1');
  end
  obj.roithresh = val;
  h = obj;
else
  h = obj.roithresh;
end