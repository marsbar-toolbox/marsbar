function D = ui_build(D, dtype)
% method to create / fill design via GUI
% FORMAT D = ui_build(D, dtype)
%
% D      - design object
% dtype  - one of 'PET', 'FMRI', 'Basic')
% 
% Returns
% D      - design object with new design
%
% $Id$

if nargin < 2
  error('Need design type');
end

switch lower(dtype)
 case 'pet'
  SPM = pr_spm_ui('cfg',spm_spm_ui('DesDefs_PET'));
 case 'basic'
  SPM = pr_spm_ui('cfg',spm_spm_ui('DesDefs_Stats'));
 case 'fmri'
  SPM = pr_fmri_design;
 otherwise
  error(['Did not recognize design type: ' dtype]);
end
D = des_struct(D, SPM);