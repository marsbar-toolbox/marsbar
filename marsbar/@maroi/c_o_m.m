function pt = c_o_m(o, sp, pt_type)
% c_o_m method - calculates unweighted centre of mass
%
% $Id$

if nargin < 2
  sp = native_space(o);
end
if nargin < 3
  pt_type = 'real';
end
coords = voxpts(o, sp);
switch pt_type
 case {'real','mm'}
  coords = realpts(o, sp);
 case 'vox'
  coords = voxpts(o, sp);
 otherwise
  error(['Do not recognize point type' pt_type]);
end
pt = mean(coords, 2);