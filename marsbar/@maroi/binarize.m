function h = binarize(obj, val)
% binarize - returns / sets binarize value for object
%
% $Id$

if nargin > 1
  if ~(val == 0 | val == 1)
    error('binarize is 0 or 1 flag');
  end
  obj.binarize = val;
  h = obj;
else
  h = obj.binarize;
end