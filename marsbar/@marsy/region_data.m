function rd = region_data(o, r_nos)
% method returns data for region(s) as cell array
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
y_f = isfield(st, 'Y');

if ~r_f & ~y_f
  error('No data to fetch for regions');
end

r_st = [];
for i = 1:length(r_nos)
  if r_f
    r_st = st.regions{r_nos(i)};
  end
  if isfield(r_st, 'Y')
    rd{i} = r_st.Y;
  elseif y_f    
    rd{i} = st.Y(:,r_nos(i));
  else
    error('No data to fetch for region');
  end
end
  
  
  