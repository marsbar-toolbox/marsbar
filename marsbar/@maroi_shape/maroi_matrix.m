function o2 = maroi_matrix(o, space)
% method to convert shape objects to maroi_matrix objects
%
% $Id$

if nargin < 2
  space = [];
end
if isempty(space)
   space = native_space(o);
end	
if isempty(space)
   error('Need space to create maroi_matrix');
end

params = paramfields(o);
params.mat = space.mat;
dim = space.dim(1:3);
params.dat = zeros(dim);

[pts vals] = voxpts(o, space);
dinds = pts(1,:) + ...
	(pts(2,:)-1) * dim(1) + ...
	(pts(3,:)-1) * dim(1)*dim(2);

params.dat(dinds) = vals;
o2 = maroi_matrix(params);