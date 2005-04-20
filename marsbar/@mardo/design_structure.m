function r = design_structure(o, xX)
% method to get or set SPM design structure
% 
% $Id$

SPM = des_struct(o);
if nargin < 2
  r = mars_struct('getifthere', SPM, 'xX');
else
  SPM.xX = xX; 
  r = des_struct(o, SPM);
end