function tf = has_autocorr(o)
% returns 1 if object contains autocorrelation specification
%
% $Id$
  
tf = 0;
des = des_struct(o);
if isfield(des, 'xVi')
  tf = isfield(des.xVi, 'Vi') | isfield(des.xVi, 'V');
end
