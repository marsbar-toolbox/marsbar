function Vo = spm_close_vol(Vi)
% Close image volume - for SPM2 / SPM99 compatibility
% See: spm_create_vol and spm_write_plane.
%
% SPM99 seems to use spm_create_image to close volumes
%
% $Id$  
  
for i=1:prod(size(Vi)),
  Vo(i) = spm_create_image(Vi(i));
end
