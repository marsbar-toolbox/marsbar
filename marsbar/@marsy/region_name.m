function rn = region_name(o, r_nos)
% gets region names as cell array
% 
% $Id$

r = n_regions(o);
if nargin < 2
  r_nos = 1:r;
end
if any(r_nos > r)
  error('Region numbers too large');
end

st = y_struct(o);
r_f = isfield(st, 'regions');
r_st = [];
for i = 1:length(r_nos)
  if r_f
    r_st = st.regions{r_nos(i)};
  end
  if isfield(r_st, 'name')
    rn{i} = r_st.name;
  else
    rn{i} = sprintf('region_%d', r_nos(i));
  end
end
