function tf = can_summarize(o)
% returns 1 if object contains enough information to be summarized
% 
% $Id$
  
st = y_struct(o);
tf = isfield(st, 'Y');