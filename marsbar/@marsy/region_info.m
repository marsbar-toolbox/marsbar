function ri = region_info(o, r_nos)
% gets region info fields as cell array
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
  if isfield(r_st, 'info')
    ri{i} = r_st.info;
  else
    ri{i} = struct([]);
  end
end
