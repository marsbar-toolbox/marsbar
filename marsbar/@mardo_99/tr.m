function t = tr(o)
% method returns TR in seconds, or empty if not available
% 
% $Id$
  
t = [];
SPM = des_struct(o);
if mars_struct('isthere', SPM, 'xX', 'RT')
  t = SPM.xX.RT;
end
