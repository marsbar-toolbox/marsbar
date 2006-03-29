function V = mars_vol(P)
% return spm vol struct for input P
% FORMAT V = mars_vol(P)
% 
% Wrapper for spm_vol function, that checks of P is vol struct already,
% and converts to current vol struct type if so. 
% 
% See spm_vol for details on arguments
% 
% $Id$
  
if nargin < 1
  V = mars_vol_utils('def_vol');
  return
end
if mars_vol_utils('is_vol', P)
  V = mars_vol_utils('convert', P);
  return
end
V = spm_vol(P);