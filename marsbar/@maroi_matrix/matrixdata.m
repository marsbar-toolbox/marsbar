function dat = matrixdata(o, dat)
% matrixdata method - gets matrix from ROI object
%
% $Id$

% a warning here about empty matrices  
if nargin > 1 % call to set matrix data
  if ~isa(o, 'maroi_matrix')
    error('Cannot set matrix from non maroi_matrix object');
  end 

  % apply implied thresholding
  tmp = find(isnan(dat) | abs(dat) < roithresh(o));
  if binarize(o), dat(:) = 1; end
  dat(tmp) = 0;

  o.dat = dat;
  dat = o;

else
  dat = o.dat;
end