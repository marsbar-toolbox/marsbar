function h = spm_hold(obj, val)
% hold - returns / sets hold value for object
%
% $Id$

if nargin > 1
  obj.spm_hold = val;
  h = obj;
else
  h = obj.spm_hold;
end