function f = fwhm(o)
% method returns FWHM, or empty if not available
% 
% $Id: tr.m,v 1.1 2004/01/26 22:08:55 matthewbrett Exp $
  
f = [];
SPM = des_struct(o);
if mars_struct('isthere', SPM, 'FWHM')
  f = SPM.FWHM;
end
