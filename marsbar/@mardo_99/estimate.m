function [marsD] = estimate(marsD, marsY, flags)
% estimate method - estimates GLM for SPM99 model
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
  flags = {''};
end
if ischar(flags), flags = {flags}; end

% get SPM design structure
SPM = des_struct(marsD);
  
% do estimation
SPM = pr_estimate(SPM, marsY);
SPM.marsY = marsY;

% return modified structure
marsD = des_struct(marsD, SPM);

