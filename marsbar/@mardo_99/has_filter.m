function tf = has_filter(o)
% returns 1 if object contains filter
%
% $Id$
  
tf = 0;
des = des_struct(o);
if isfield(des, 'xX')
  tf = isfield(des.xX, 'K');
end
