function h = history(obj, val)
% history - returns / sets history value for object
%
% $Id$

if nargin > 1
  obj.history = val;
  h = obj;
else
  h = obj.history;
end