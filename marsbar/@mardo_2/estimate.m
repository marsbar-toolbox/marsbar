function [marsD] = estimate(marsD, marsY, params)
% estimate method - estimates GLM for SPM2 model
%
% marsD           - SPM design object
% marsY           - MarsBaR data object or 2D data matrix
% params          - struct containing options, as fields
%                   redo_covar     - if 1, remodels covariance 
%                   redo_whitening - if 1, recalcalates whitening
%                   (by default, both are set to 1)
% 
% e.g.
% % Estimate model on design D and data Y, using original covariance and
% % whitening
% E = estimate(D, Y, struct('reco_covar', 0, ...
%                           'redo_whitening', 0);
%  
% $Id$

def_params = struct(...
    'redo_covar', 1, ...
    'redo_whitening', 1);

if nargin < 2
  error('Need data to estimate');
end
if nargin < 3
  params = [];
end

% Replicate original behaviour calling with cell array of strings
params = sf_call_compat(params);

% Fill with defaults
params = mars_struct('ffillmerge', def_params, params);

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

% process params
if params.redo_covar
  if isfield(SPM, 'xVi') 
    if isfield(SPM.xVi, 'V') & isfield(SPM.xVi, 'Vi')
      SPM.xVi = rmfield(SPM.xVi, 'V');
      if verbose(marsD)
	disp('Re-estimating covariance');
      end
    end
  end
end
if params.redo_whitening
  if isfield(SPM.xX, 'W')
    SPM.xX = rmfield(SPM.xX, 'W');
    if verbose(marsD)
      disp('Re-estimating whitening filter');
    end
  end
end

SPM        = pr_estimate(SPM, marsY);
SPM.marsY  = marsY;
SPM.SPMid  = sprintf('SPM2: MarsBaR estimation. mardo_2 version %s', ...
		     marsD.cvs_version);

% return modified structure
marsD = des_struct(marsD, SPM);

return

function params = sf_call_compat(params)
% Replicates old calling behaviour, for backwards compatibility
  
% Replicate result of passing empty cell array, but warn that this
% will be removed soon  
if ischar(params) | iscell(params)
  warning(['Cell / char form of params deprecated, ' ...
	   'please use struct form instead']);
end
if iscell(params) & isempty(params)
  warning(['Empty cell array changes default options; '...
	  'This behaviour will change for future versions']);
  params = struct(...
    'redo_covar', 0, ...
    'redo_whitening', 0);
end
if ischar(params)params = {params}; end
if iscell(params)
  params = params(:); 
  params = cell2struct(num2cell(ones(size(params))), params, 1);
end
return