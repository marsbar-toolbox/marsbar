function r = marsy_data(o, Y)
% method to get or set marsy data
% 
% $Id$
  
if nargin < 2
  r = get_data(o);
else
  r = set_data(o, Y);
end