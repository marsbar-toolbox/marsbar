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

if iscell(imgs)
  imgs = char(imgs);
end
if ischar(imgs)
  imgs = full_vol(D, imgs);
end
if isstruct(imgs)
  V = imgs;
  fnames = spm_str_manip(strvcat(imgs(:).fname), 't');
  for i = 1:prod(size(imgs))
    V(i).fname = deblank(fnames(i,:));
  end
else
  error('Odd input format for images');
end

