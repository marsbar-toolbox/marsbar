function [pts, vals] = voxpts(obj, sp)
% voxpts method - voxels within a box in given space
%
% $Id$

if nargin < 2
  error('Need object and space arguments');
end
sp = mars_space(sp);

mc = obj.centre;
mw = obj.widths;

% find voxels that are within box
dim = sp.dim(1:3); dim = dim(:);
vox = sqrt(sum(sp.mat(1:3,1:3)'.^2));
vd = mw ./ vox / 2;
vc = sp.mat \ [mc(1:3) 1]';
vc = vc(1:3)';
blim = [max([1 1 1; ceil(vc-vd)]); min([sp.dim(1:3); floor(vc+vd)])];
[R,C,P]=ndgrid(...
    blim(1,1):blim(2,1),blim(1,2):blim(2,2),blim(1,3):blim(2,3));
pts = [R(:)';C(:)';P(:)'];

vals = ones(1, size(pts, 2));