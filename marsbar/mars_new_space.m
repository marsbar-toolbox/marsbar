function [dim2, mat2, vox2] = mars_new_space(dim, mat, vox)
% make a new image space to contain image with rotations etc
% FORMAT [dim2, mat2, vox2] = mars_new_space(dim, mat, vox)
% 
% dim        - original dimensions in voxels
% mat        - orignal mat file (4x4 transformation matrix)
% vox        - required ouput voxel size
% 
% OUTPUT
% dim2       - new dimensions
% mat2       - new mat file
% vox2       - new voxel dimensions
%
% $Id$

if nargin < 2
  error('Need two input args');
end
dim = dim(:);
dim = dim(1:3)';
if nargin < 3
  vox = [];
end

% size, opposite corners of transformed img in mm
[sz mn_mx] = mmsz(dim, mat);

% select new voxel size if needed
if isempty(vox) 
  % original voxel size
  vox = sqrt(sum(mat(1:3,1:3).^2));

  % XYZ max difference for one voxel
  vxsz = mmsz([1 1 1], mat);

  % reassign original dimensions to best matching
  % of new dimensions
  [t o] = sort(vxsz);
  vox2(o) = sort(vox);
else
  vox2 = vox;
end

% new dimensions add 1 to allow for half voxel at either
% side of voxel centres, allowing for rounding
dim2 = sz./vox2 + 1;
rdim2 = round(dim2);
tiny = 1e-12;
for d = 1:3
 if (dim2(d) - rdim2(d))<tiny
   dim2(d) = rdim2(d);
 else
   dim2 = ceil(dim2(d));
 end
end

% set new voxel sizes in output mat
mat2 = diag([vox2 1]);

% translations are from left post inf vox co-ord to mm coord
% left post inf corner of new image
mat2(1:3,4) = [mn_mx(1,:) - vox2]'; 

return

function [sz, mn_mx]  = mmsz(dim, mat);
% returns size in mm of matrix dim;
  
% 8 corners in voxels of original image
i = [1 1 1; eye(3)];
i = logical([i; ~i]);
corners = ones(8,1) * dim;
corners(i) = 1;

% corners in mm
mm_c = mat * [corners'; ones(1, 8)];

% min and max of XYZ of corners in mm
mm_c = sort(mm_c(1:3, :)');
mn_mx = mm_c([1 end],:);

% size is the difference
sz = diff(mn_mx);
  