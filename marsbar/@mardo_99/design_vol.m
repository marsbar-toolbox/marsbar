function V = design_vol(D, imgs)
% returns vols in appropriate format for saving in design
% FORMAT V = design_vol(D, imgs)
%
% Input 
% D           - mardo design object
% imgs        - image names or vol structs
% 
% Output
% V           - paths relative to swd
%
% $Id$

if nargin < 2
  error('Need image information');
end

if isstruct(imgs) % vol struct, check for absolute path name
  imgs = strvcat(imgs(:).fname);
end
if iscell(imgs)
  imgs = char(imgs);
end
if ischar(imgs)
  V = spm_str_manip(imgs, 't');
else
  error('Odd input format for images');
end

