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
xX = SPM.xX;

%-Append contrasts for fMRI - specified by SPM.Sess(s).Fc(i)
%-----------------------------------------------------------------------
if ~isfield(SPM,'Sess')
  changef = 0;
  return;
end

Sess = SPM.Sess;
xCon = [];
if (Sess{1}.rep)
  for t = 1:length(Sess{1}.name)
    u     = [];
    for s = 1:length(Sess)
      u = [u Sess{s}.col(Sess{s}.ind{t})];
    end
    q             = 1:size(xX.X,2);
    q(u)          = [];
    Fcname        = Sess{s}.name{t};
    xcon          = spm_FcUtil('Set',Fcname,'F','iX0',q,xX.xKXs);
    xCon          = [xCon xcon];
  end
else % Sessions are not repeated 
  for s = 1:length(Sess)
    str   = sprintf('Session %d: ',s);
    for t = 1:length(Sess{s}.name)
      q             = 1:size(xX.X,2);
      q(Sess{s}.col(Sess{s}.ind{t})) = [];
      Fcname        = [str Sess{s}.name{t}];
      xcon          = spm_FcUtil('Set',Fcname,'F','iX0',q,xX.xKXs);
      xCon          = [xCon xcon];
    end
  end
end

[D Ic changef] = add_contrasts(D, xCon);