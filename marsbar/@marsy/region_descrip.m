function rd = region_descrip(o, r_nos)
% gets region descrips as cell array
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
  if isfield(r_st, 'descrip')
    rd{i} = r_st.descrip;
  else
    rd{i} = '';
  end
end
