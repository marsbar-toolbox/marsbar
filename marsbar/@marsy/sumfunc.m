function o = sumfunc(o, sumfunc)
% method to get or set sumfunc
%
% $Id$

if nargin < 2
  % get
  o = o.y_struct.sumfunc;
else
  % set
  o.y_struct.sumfunc = sumfunc;
end