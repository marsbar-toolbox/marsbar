function XYZ = xyz(o, r_no, xyz_type)
% gets XYZ coordinates for region 
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
st = y_struct(o);
if ~isfield(st, 'regions')
  return
end
r_st = st.regions{r_no};
if ~isfield(r_st, 'vXYZ') |  ~isfield(r_st, 'mat')
  return
end
M = r_st.mat;
XYZ = r_st.vXYZ;
switch xyz_type
 case 'voxels'
 case {'mm', 'real'}
  if ~isempty(XYZ)
    tmp = M * [XYZ; ones(1, size(XYZ, 2))];
    XYZ = XYZ(1:3,:);
  end
 otherwise
  error(['Unknown coordinate type: ' xyz_type]);
end
