function r = contrasts(o, xcon)
% method to get or set contrasts
% 
% $Id$
  
if nargin < 2
  r = get_contrasts(o);
else
  r = set_contrasts(o, xcon);
end