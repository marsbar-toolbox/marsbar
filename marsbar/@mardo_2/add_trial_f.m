function [D, changef] = add_trial_f(D)
% method to add trial-specific F contrasts  
% 
% D         - design to put contrasts into
%
% Returns
% D         - design with any added contrasts
% changef   - set to 1 if any contrasts have been added
%  
% The routine only adds contrasts that are not already present
%
% $Id$
  
if ~strcmp(modality(D), 'fmri')
  error('Can only set trial-specific F contrasts for FMRI designs');
end
SPM = des_struct(D);
xX            = SPM.xX;
[nScan nBeta] = size(xX.X);

%-Append contrasts for fMRI - specified by SPM.Sess(s).Fc(i)
%-----------------------------------------------------------------------
xCon = [];
if isfield(SPM,'Sess')
  for s = 1:length(SPM.Sess)
    for i = 1:length(SPM.Sess(s).Fc)
      iX0           = 1:nBeta;
      iX            = SPM.Sess(s).col(SPM.Sess(s).Fc(i).i);
      iX0(iX)       = [];
      Fcname        = sprintf('Sess(%d):%s',s,SPM.Sess(s).Fc(i).name);
      xcon          = spm_FcUtil('Set',Fcname,'F','iX0',iX0,xX.xKXs);
      xCon          = [xCon xcon];
    end
  end
end
[D Ic changef] = add_contrasts(D, xCon);