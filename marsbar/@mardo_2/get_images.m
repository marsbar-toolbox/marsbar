function VY = get_images(marsD)
% method to get image vols from design
% FORMAT VY = get_images(marsD)
% 
% $Id$
    
D = des_struct(marsD);
VY = D.xY.VY;