function r = betas(o, Y)
% method to get estimated betas
% 
% $Id$

if ~is_mars_estimated(o)
  error('No betas, model not estimated');
end
r = o.betas;
