function M =bare_head(fname)
% returns bare header (pre mat file) mat info
%
% $Id$

[dim vox scale typ offset origin] = spm_hread(fname);
 
% If origin hasn't been set, then assume
% it is the centre of the image.
if (all(origin == 0)),origin = dim(1:3)/2;end
if (all(vox == 0)),vox = [1 1 1];end
off = -vox.*origin;
M = [vox(1) 0 0 off(1) ; 0 vox(2) 0 off(2) ; 0 0 vox(3) off(3) ; 0 0 0 1];