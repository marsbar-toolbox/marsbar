function [m,n] = region_size(o, r_no, dim)
% method to get size of specified region data
% FORMAT [m,n] = region_size(o, r_no, dim)
%
% Input
% o        - marsy object
% r_no     - region number OR vector of region numbers 
%            OR 'all' ['all' is default] 
% dim      - [optional] dimension size to return
%
% Output
% m        - as for matlab SIZE call
% n        -
%
% e.g 
% % returns total number of timepoints (sz(1) and samples (sz(2) 
% % in all regions
% sz = region_size(o); 
% % same thing
% sz = region_size(o, 'all');
% % number of samples in region 2
% n = region_size(o, 2, 2);
%
% $Id$ 

r = n_regions(o);
if nargin < 2
  r_no = 'all';
end
if ischar(r_no)
  if strcmp(lower(r_no), 'all')
    r_no = 1:r;
  else
    error(['Surprise request of ' r_no]);
  end
else
  if any(r_no > r | r_no < 1)
    error('Region number(s) out of range');
  end
end

st = y_struct(o);
r_f = isfield(st, 'regions');
y_f = isfield(st, 'Y');

if ~r_f & ~y_f
  error('No information for region data size');
end

n = 0;
for r = r_no
  r_st = [];
  if r_f, r_st = st.regions{r}; end
  if isfield(r_st, 'Y')
    [m n_r] = size(r_st.Y);
    n = n + n_r;
  elseif y_f    
    m = size(st.Y, 1);
    n = n + 1;
  else
    error('No data to get size for region');
  end
end

if nargin < 3
  if nargout < 2
    m = [m n];
  end
else  
  if dim == 2
    m = n;
  elseif dim > 2
    m = ((m+n) > 0);
  end
end
