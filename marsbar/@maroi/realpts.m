function [pts, vals] = realpts(o,sp)
% realpts method - returns 3xN XYZ matrix in mm
%
% $Id$

if nargin < 2
  error('Need space definition to find voxels');
end
[pts vals] = voxpts(o, sp); 

if ~isempty(pts)
  pts = sp.mat * [pts; ones(1, size(pts,2))];
  pts = pts(1:3,:);
end