function o = sumfunc(o, sumfunc)
% method to get or set sumfunc
%
% $Id$

if nargin < 2
  % get
  st = y_struct(o);
  if isfield(st, 'sumfunc')
    o = st.sumfunc;
  else
    o = '';
  end
else
  % set
  o.y_struct.sumfunc = sumfunc;
end