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

% Check data and design dimensions
if size(marsY.Y, 1) ~= size(SPM.xX.X, 1)
  error('The data and design must have the same number of rows');
end

% process flags
if strmatch('redo_covar', flags)
  if isfield(SPM.xVi, 'V')
    SPM.xVi = rmfield(SPM.xVi, 'V');
    if verbose(marsD)
      disp('Re-estimating covariance');
    end
  end
end
if strmatch('redo_whitening', flags)
  if isfield(SPM.xX, 'W')
    SPM.xX = rmfield(SPM.xX, 'W');
    if verbose(marsD)
      disp('Re-estimating whitening filter');
    end
  end
end

% do estimation
SPM = pr_estimate(SPM, marsY);
SPM.marsY = marsY;

% return modified structure
marsD = des_struct(marsD, SPM);

