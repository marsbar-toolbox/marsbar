function [marsD] = estimate(marsD, marsY, flags)
% estimate method - estimates GLM for SPM99 model
%
% marsD           - SPM design object
% marsY           - MarsBaR data object, or 2D matrix
% flags           - cell array of options
%
% $Id$

if nargin < 2
  error('Need data to estimate');
end
if nargin < 3
  flags = {''};
end
if ischar(flags), flags = {flags}; end

% ensure we have a data object
marsY = marsy(marsY);

% check design is complete
if ~can_mars_estimate(D)
  error('This design needs more information before it can be estimate');
end

% Check data and design dimensions
if n_time_points(marsY) ~= n_time_points(marsD)
  error('The data and design must have the same number of rows');
end

% get SPM design structure
SPM = des_struct(marsD);
  
% do estimation
SPM       = pr_estimate(SPM, marsY);
SPM.marsY = marsY;
SPM.SPMid = marsD.cvs_version;

% return modified structure
marsD = des_struct(marsD, SPM);

