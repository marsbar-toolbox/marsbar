function C = get_contrasts(D)
% method to get contrasts from design object
% 
% $Id$
  
C = [];
SPM = des_struct(D);
if isfield(SPM, 'xCon');
  C = SPM.xCon;
end