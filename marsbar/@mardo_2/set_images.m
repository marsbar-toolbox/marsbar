function marsD = set_images(marsD, VY)
% method to set image vols to design
% 
% $Id% 
  
if nargin < 2
  error('Need image volumes');
end
D = des_struct(marsD);
D.xY.VY = VY;
D.xY.P = strvcat(VY(:).fname);
marsD = des_struct(marsD, D);
