function [m,n] = region_size(o, r_no, dim)
% method to get size of specified region data
% 
% $Id$ 

r = n_regions(o);
if nargin < 2
  error('Need region number');
end
if r_no > r
  error('Region number too large');
end

st = y_struct(o);
r_f = isfield(st, 'regions');
y_f = isfield(st, 'Y');

if ~r_f & ~y_f
  error('No information for region data size');
end

r_st = [];
if r_f
  r_st = st.regions{r_no};
end
if isfield(r_st, 'Y')
  sz = size(r_st.Y);
elseif y_f    
  sz = [size(st.Y, 1), 1];
else
  error('No data to get size for region');
end

if nargin < 3
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
