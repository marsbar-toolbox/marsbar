function r = masking_struct(o, xM)
% method to get or set SPM masking structure
% 
% $Id$

SPM = des_struct(o);
if nargin < 2
  r = mars_struct('getifthere', SPM, 'xM');
else
  SPM.xM = xM; 
  r = des_struct(o, SPM);
end