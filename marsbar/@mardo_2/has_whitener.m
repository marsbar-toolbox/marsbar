function tf = has_whitener(D)
% returns 1 if design has whitening filter
%
% $Id$

tf = 0;
SPM = des_struct(D);
if isfield(SPM, 'xX')
  tf = isfield(SPM.xX, 'W');
end