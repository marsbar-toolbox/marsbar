function marsD = set_images(marsD, VY)
% method to set image vols into design
% 
% $Id$ 
  
if nargin < 2
  error('Need image volumes');
end
D = des_struct(marsD);
D.VY = VY;
marsD = des_struct(marsD, D);