function o_arr = split(o)
% method splits regions in object into separate objects
% 
% $Id$ 
  
r = region(o);
st = y_struct(o);
is_s = isfield(st, 'Y') & isfield(st, 'Yvar');
if is_s
  Y = st.Y;
  Yvar = st.Yvar;
else
  % remove any rogue Y or Yvar fields
  st = mars_struct('strip', st, {'Y','Yvar'});
end
for i = 1:length(r)
  r_st = st;
  r_st.regions = r(i);
  if is_s
    r_st.Y    = Y(:, i);
    r_st.Yvar = Yvar(:, i);
  end
  o_arr(i) = y_struct(o, r_st);
end
