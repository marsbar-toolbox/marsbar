function mod_str = modality(D)
% method returns modality of design
%
% $Id$ 
  
SPM = des_struct(D);
try
  SPM.Sess(1);
  mod_str = 'fmri';
catch
  mod_str = 'pet';
end
