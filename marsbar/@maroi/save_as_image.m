function v = save_as_image(o, fname, sp)
% method save_as_image - saves ROI as image
%
% $Id$

if nargin < 2
  error('Need ROI and filename');
end
if nargin < 3
  sp = [];
end
o = maroi_matrix(o, sp);
v = do_write_image(o, fname);