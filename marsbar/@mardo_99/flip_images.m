function o = flip_images(o)
% flips images in design
if ~has_images(o), return, end
M = diag([-1 1 1 1]);
des = des_struct(o);
for i = 1:length(des.VY)
  des.VY(i).mat = M * des.VY(i).mat;
end
o = des_struct(o,des);  