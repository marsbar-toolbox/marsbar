function dat = matrixdata(o, dat)
% matrixdata method - gets matrix from ROI object
%
% $Id$

% a warning here about empty matrices  
if nargin > 1 % call to set matrix data
  % change to maroi_matrix type before setting data
  o = maroi_matrix(o);
  
  % apply implied thresholding
  tmp = find(isnan(dat) | abs(dat) < roithresh(o));
  if binarize(o), dat(:) = 1; end
  dat(tmp) = 0;

  o.dat = dat;
  dat = o;

else
  dat = o.dat;
end