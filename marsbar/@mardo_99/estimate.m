function [marsD] = estimate(marsD, marsY, params)
% estimate method - estimates GLM for SPM99 model
%
% marsD           - SPM design object
% marsY           - MarsBaR data object, or 2D matrix
% param           - struct containing options
%                    (not currently used)
%
% e.g.
% % Estimate model on design D and data Y
% E = estimate(D, Y);
%
% $Id$

if nargin < 2
  error('Need data to estimate');
end
if nargin < 3
  params = [];
end

% ensure we have a data object
marsY = marsy(marsY);

% check design is complete
if ~can_mars_estimate(marsD)
  error('This design needs more information before it can be estimated');
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

% We must set SPMid to contain SPM99 string in order for the mardo_99 to
% recognize this as an SPM99 design
SPM.SPMid  = sprintf('SPM99: MarsBaR estimation. mardo_99 version %s', ...
		     marsD.cvs_version);

% return modified structure
marsD = des_struct(marsD, SPM);

