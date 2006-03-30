function V = full_vol(D, imgs)
% returns vol with full path, from vols, or image names
% FORMAT V = full_vol(D, imgs)
%
% Input 
% D           - mardo design object
% imgs        - image names or vol structs
% 
% Output
% V           - vol structs with full path names
% 
% If the filename for the image does not exist, the routine returns an
% empty vol struct - which has the filename set, but all other fields are
% empty
%
% $Id$

if nargin < 2
  error('Need image information');
end

Swd = swd(D);
if isempty(Swd)
  error('Need directory of design; it is missing');
end

def_struct = mars_vol_utils('def_vol');

if isempty(imgs)
  V = def_struct; 
  return
end

if iscell(imgs)
  imgs = char(imgs);
end
if isstruct(imgs) % vol struct, check for absolute path name
  V = imgs;
  nimgs = prod(size(imgs));
  for i = 1:nimgs
    fname = V(i).fname;
    if ~mars_utils('isabspath', fname);
      fname = fullfile(Swd, fname);
    end
    V(i).fname = fname;
  end
elseif ischar(imgs)
  for i = 1:size(imgs, 1)
    fname = deblank(imgs(i,:));
    if ~mars_utils('isabspath', fname)
      fname = fullfile(Swd, fname);
    end
    if exist(fname, 'file')
      V(i) = spm_vol(fname);
    else
      V(i).fname = fname;
    end
  end  
else
  error('Odd input format for images');
end

