function [pts, vals] = voxpts(obj, sp)
% voxpts method - returns 3xN ijk matrix in voxels
%
% $Id$

if nargin < 2
  error('Need space to give voxel points');
end
[pts, vals] = rebase(obj, sp, '');