function bms = block_means(D)
% method returns means for blocks in design
% 
% $Id$

bms = [];
if ~is_mars_estimated(D)
  return
end

SPM = des_struct(D);
bms = SPM.betas(SPM.xX.iB,:);   
  
