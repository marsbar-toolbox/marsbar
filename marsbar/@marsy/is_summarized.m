function tf = is_summarized(o)
% returns 1 if object contains calculated summary data
% 
% $Id$
  
st = y_struct(o);
tf = isfield(st, 'Y') & isfield(st, 'Yvar');