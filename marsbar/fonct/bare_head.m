function M =bare_head(fname)
% returns bare header (pre mat file) mat info
%
% $Id$

[pth,nam,ext] = fileparts(deblank(fname));
hfname = fullfile(pth,[nam '.hdr']);
if exist(hfname, 'file')
  hdr = spm_read_hdr(hfname);
  
  % If origin hasn't been set, then assume
  % it is the centre of the image.
  if any(hdr.hist.origin(1:3)),
    origin = hdr.hist.origin(1:3);
  else,
    origin = (hdr.dime.dim(2:4)+1)/2;
  end;
  vox    = hdr.dime.pixdim(2:4);
else
  % not an analyze image I guess
  V = spm_vol(fname);
  origin = (V.dim(1:3)+1)/2;
  vox = sqrt(sum(V.mat(1:3,1:3).^2));
end

if (all(vox == 0)),vox = [1 1 1];end
off = -vox.*origin;
M = [vox(1) 0 0 off(1) ; 0 vox(2) 0 off(2) ; 0 0 vox(3) off(3) ; 0 0 0 1];