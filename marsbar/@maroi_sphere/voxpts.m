function [pts, vals] = voxpts(obj, sp)
% voxpts method - voxels within a sphere in given space
%
% $Id$

if nargin < 2
  error('Need object and space arguments');
end
sp = mars_space(sp);

mc = obj.centre;
mr = obj.radius;

% find voxels that are within sphere
vox = sqrt(sum(sp.mat(1:3,1:3)'.^2));
vr = mr ./ vox;
vc = sp.mat \ [mc(1:3) 1]';
vc = vc(1:3)';
blim = [max([1 1 1; ceil(vc-vr)]); min([sp.dim(1:3); floor(vc+vr)])];
[R,C,P]=ndgrid(...
    blim(1,1):blim(2,1),blim(1,2):blim(2,2),blim(1,3):blim(2,3));
vXYZ = [R(:)';C(:)';P(:)'];
o = ones(1, size(vXYZ, 2));
pts = find(sqrt(sum(((vXYZ-(vc'*o)) .* (vox'*o)).^2)) <= mr);
pts = vXYZ(:,pts);
vals = ones(1, size(pts, 2));