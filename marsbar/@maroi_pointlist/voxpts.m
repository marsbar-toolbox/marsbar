function [pts, vals] = voxpts(o, sp)
% voxpts method - returns 3xN ijk matrix in voxels
%
% $Id$

if nargin < 2
  error('Need space for voxpts call')
end

sp = mars_space(sp);

% to maroi_matrix object
mo = maroi_matrix(o);

% and return values
[pts, vals] = voxpts(mo, sp);