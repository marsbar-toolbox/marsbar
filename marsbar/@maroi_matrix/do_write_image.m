function v = do_write_image(o, fname)
% save_as_image method - saves matrix as image and returns spm_vol
%
% $Id$

v = struct('fname', fname,...
	   'mat', o.mat,...
	   'pinfo', [1 0 0]',...
	   'dim', size(o.dat));
if binarize(o)
  v.dim(4) = spm_type('uint8');
else
  v.dim(4) = spm_type('float');
end
v = spm_create_image(v);
v = spm_write_vol(v, o.dat);