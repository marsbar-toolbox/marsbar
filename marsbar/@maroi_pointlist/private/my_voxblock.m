function vblock = my_voxblock(pts, mat, vals)
% returns voxel block and modified mat file for pointlist
%
% $Id$

if isempty(vals)
  vals = ones(1, size(pts,2));
end

% dimensions of containing block
st = min(pts, [], 2)';
fn = max(pts, [], 2)';
dsz = fn-st+1;

% reset mat according to voxel block
newM = mat * spm_matrix(st-1);

% set voxels in block
dat1 = zeros(dsz);
dpts = pts - (st'-1) * ones(1, size(pts,2)); 
dinds = dpts(1,:) + ...
	(dpts(2,:)-1) * dsz(1) + ...
	(dpts(3,:)-1) * dsz(1)*dsz(2);
dat1(dinds) = vals;

% add a shell of one voxel to isolate from interpolation 0s
dat = zeros(dsz+2);
dat(2:end-1,2:end-1,2:end-1) = dat1;
mat = newM * spm_matrix([-1 -1 -1]);

vblock = struct('dat', dat, 'mat', mat);