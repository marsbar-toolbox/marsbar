function res = summary_descrip(o, descrip)
% get/set method for summary data description
% 
% $Id$ 
  
st = y_struct(o);
if nargin < 2 % get
  res = '';
  if isfield(st, 'descrip')
    res = st.descrip;
  end
else % set
  st.descrip = descrip;
  o = y_struct(o, st);
  res = o;
end