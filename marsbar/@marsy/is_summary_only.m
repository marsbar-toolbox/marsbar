function tf = is_summary_only(o)
% method returns 1 if object only contains summary data
% 
% $Id$

tf = 0;
st = y_struct(o);
if isfield(st, 'Y')
  if ~isfield(st, 'regions')
    tf = 1;
  else
    Y = region_data(o);
    Y = [Y{:}];
    tf = size(Y, 2) == size(st.Y, 2);
  end
end
