function tf = is_spm_estimated(D)
% returns 1 if design has been estimated in SPM
% 
% $Id$ 
  
tf = isfield(D.des_struct, 'VResMS');