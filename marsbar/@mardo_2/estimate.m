function [marsD] = estimate(marsD, marsY, flags)
% estimate method - estimates GLM for SPM2 model
%
% marsD           - SPM design object
% marsY           - MarsBaR data structure
% flags           - cell array of options
%
% $Id$

if nargin < 2
  error('Need data to estimate');
end
if nargin < 3
  flags = {'redo_covar','redo_whitening'};
end
if ischar(flags), flags = {flags}; end

% get SPM design structure
SPM = des_struct(marsD);
  
% process flags
if ismember(flags, 'redo_covar')
  SPM.xVi = rmfield(SPM.xVi, 'V');
  if verbose(marsD)
    disp('Re-estimating covariance');
  end
end
if ismember(flags, 'redo_whitening')
  SPM.xX = rmfield(SPM.xX, 'W');
  if verbose(marsD)
    disp('Re-estimating whitening filter');
  end
end

% do estimation
SPM = pr_estimate(SPM, marsY);
SPM.marsY = marsY;

% return modified structure
marsD = des_struct(marsD, SPM);

