function [XYZ, M]= xyz(o, r_no, xyz_type)
% gets XYZ coordinates for region 
% FORMAT [XYZ M]= xyz(o, r_no, xyz_type)
% 
% Inputs
% o         - marsy object
% r_no      - region number
% xyz_type  - string, one of 'mm','real','vox' 
%             where 'real' is a synonym for 'mm'
%             and 'mm' is the default (if not passed)
%             'mm' results in coordinates in mm
%             'vox' gives coordinates in voxels
% 
% Outputs
% XYZ       - coordinates in specified reference
% M         - 4x4 transformation mapping voxels to mm
% 
% $Id$

r = n_regions(o);
if nargin < 2
  error('Need region number to get XYZ coordinates')
end
if r_no > r
  error('Region number too large');
end
if nargin < 3
  xyz_type = 'mm';
end

XYZ = [];
M = eye(4);
st = y_struct(o);
if ~isfield(st, 'regions')
  return
end
r_st = st.regions{r_no};
if ~isfield(r_st, 'vXYZ') |  ~isfield(r_st, 'mat')
  return
end
XYZ = r_st.vXYZ;
if isempty(XYZ), return, end
switch xyz_type
 case 'vox'
 case {'mm', 'real'}
  [m n] = size(XYZ);
  if m == 3, XYZ = [XYZ; ones(1, n)]; end
  M = r_st.mat;
  XYZ = M * XYZ;
 otherwise
  error(['Unknown coordinate type: ' xyz_type]);
end
XYZ = XYZ(1:3,:);
