function res = summary_info(o, descrip)
% get/set method for summary data info
% 
% $Id$ 
  
st = y_struct(o);
if nargin < 2 % get
  res = [];
  if isfield(st, 'info')
    res = st.info;
  end
else % set
  st.info = info;
  o = y_struct(o, st);
  res = o;
end