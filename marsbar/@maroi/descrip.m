function h = descrip(obj, val)
% name - returns / sets name value for object
%
% $Id$

if nargin > 1
  obj.descrip = val;
  h = obj;
else
  h = obj.descrip;
end