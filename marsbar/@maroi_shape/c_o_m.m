function pt = c_o_m(o, sp, pt_type)
% c_o_m method - calculates centre of mass
%
% $Id$
  
if nargin < 2
  sp = '';
end
if nargin < 3
  pt_type = 'real';
end
pt = centre(o);
switch pt_type
 case {'real','mm'}
 case 'vox'
  if isempty(sp)
    error('Need space to define voxel centre of mass');
  end
  pt = sp.mat * [pt; 1];
  pt = pt(1:3)';
 otherwise
  error(['Do not recognize point type' pt_type]);
end
