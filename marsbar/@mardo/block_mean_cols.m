function bmrs = block_mean_rows(D)
% method returns rows for means for blocks in design
% 
% $Id$

bmrs = [];
SPM =  des_struct(D);
bmrs = SPM.xX.iB;   
  
