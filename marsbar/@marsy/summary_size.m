function [m,n] = summary_size(o, dim)
% method returns number of time points x number of regions
%
% $Id$
  
st = o.y_struct;
sz = [0 0];
if isfield(st, 'Y')
  sz = size(st.Y);
elseif isfield(st, 'regions')
  if iscell(st.regions)
    if isfield(st.regions{1}, 'Y')
      sz(1) = size(st.regions{1}.Y, 1);
    end
  end
  sz(2) = length(st.regions);
end

if nargin < 2
  if nargout > 1
    m = sz(1); n = sz(2);
  else
    m = sz;
  end
else  
  if dim > 2
    m = (m+n > 0)
  else
    m = sz(dim);
  end
end