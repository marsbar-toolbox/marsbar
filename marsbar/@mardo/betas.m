function r = betas(o)
% method to get estimated betas
% 
% $Id$

if ~is_mars_estimated(o)
  error('No betas, model not estimated');
end
SPM = des_struct(o);
r   = SPM.betas;
