function v = do_write_image(o, fname)
% method saves matrix as image and returns spm_vol
%
% $Id$

v = mars_vol_utils('def_vol');
v.fname = fname;
v.mat = o.mat;
v.dim = size(o.dat);

if binarize(o)
  v = mars_vol_utils('set_type', v, 'uint8');
else
  v = mars_vol_utils('set_type', v, 'float');
end

v = spm_create_vol(v);
v = spm_write_vol(v, o.dat);