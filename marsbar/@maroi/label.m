function h = label(obj, val)
% label - returns / sets label value for object
%
% $Id$

if nargin > 1
  obj.label = val;
  h = obj;
else
  h = obj.label;
end