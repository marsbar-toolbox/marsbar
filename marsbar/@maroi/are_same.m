function tf = are_same(roi1, roi2, sp)
% returns 1 if rois are the same
% FORMAT tf = are_same(roi1, roi2)
% 
% $Id$

if nargin < 2
  error('Need two ROIs');
end
if nargin < 3
  sp  = native_space(roi1);
  if isempty(sp)
    sp = native_space(roi2);
  end
  if isempty(sp)
    error('Need space for comparison');
  end
end

mat1 = matrixdata(maroi_matrix(roi1, sp));
mat2 = matrixdata(maroi_matrix(roi2, sp));

tf = all(mat1(:)==mat2(:));