function marsD = set_images(marsD, VY)
% method to set image vols to design
if nargin < 2
  error('Need image volumes');
end
D = des_struct(marsD);
D.xY.VY = VY;
marsD = des_struct(marsD, D);
