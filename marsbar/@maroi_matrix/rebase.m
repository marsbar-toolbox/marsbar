function [pts, vals] = rebase(obj, sp, flags)
% rebase method - returns data from maroi_matrix in new space
% Unless flags contains 'i', returns [pts, vals]
% otherwise returns matrix in new space
%
% $Id$

if nargin < 2
  error('Need space to give voxel points');
end
if nargin < 3
  flags = '';
end
if isempty(flags), flags = ' ';end

sp = mars_space(sp);
vol = obj.dat;
mat = spm_mat(obj);
Hold = spm_hold(obj);
th = roithresh(obj);
binf = binarize(obj);

if any(flags == 'i')
  pts = zeros(sp.dim(1:3));
  vals = [];
else % points call
  pts = cell(1, sp.dim(3));
  multvc = cell(1, sp.dim(3));
end

for z=1:sp.dim(3),
  M = inv(mat) * sp.mat * spm_matrix([0 0 z]);
  img = spm_slice_vol(vol,M,sp.dim(1:2),Hold);
  tmp = abs(img) >= th;
  img(~tmp) = 0;
  if any(tmp(:))
    if binf, img(tmp) = 1; end
    if any(flags == 'i') % image to return
      pts(:,:,z) = img;
    else % point list
      tmp = find(tmp);
      multvc(z) = {img(tmp)'};
      tmp = tmp-1;
      y = floor(tmp/sp.dim(1));
      x = tmp - (y*sp.dim(1));
      o = ones(1, length(x));
      pts(z) = {[[x y]'+1; o*z]};
    end
  end
end
if ~any(flags == 'i')
  pts =  [pts{:}];  
  vals = [multvc{:}];
end