function o = flip_images(o)
% flips images in design
if ~has_images(o), return, end
M = diag([-1 1 1 1]);
for i = 1:length(o.des_struct.VY)
  o.des_struct.VY(i).mat = M *o.des_struct.VY(i).mat;
end
  