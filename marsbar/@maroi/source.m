function h = source(obj, val)
% source - returns / sets source value for object
%
% $Id$

if nargin > 1
  obj.source = val;
  h = obj;
else
  h = obj.source;
end