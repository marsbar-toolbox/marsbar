function res = test_rig(design_paths, params)
% runs tests on MarsBaR using specified designs
% FORMAT res = test(design_paths, params)
% 
% Inputs
% design_paths     - path(s) to SPM design files
% params           - structure giving params to pass to estimate method,
%                    see help for do_estimate methods for details
%                    Default is
%                    params = struct('redo_covar', 0, ...
%                      		  'redo_whitening', 0);
% 
% Outputs
% res              - 1 if all tests passed, 0 otherwise
% 
% The function depends on the SPM design having estimated contrasts to
% play with.  It uses these to:
% Get the maximum voxel in the first F and first T contrast
% Records the T/F statistic value
% Makes an ROI out of this voxel
% Estimates in MarsBaR
% Checks the statistic value is that same.
% 
% Along the way, it uses much of the MarsBaR machinery
% 
% $Id$ 
  
if nargin < 1
  design_paths = spm_get([0 Inf], 'SPM*.mat', 'Select SPM designs');
end
if nargin < 2
  params = struct('redo_covar', 0, ...
		  'redo_whitening', 0);
end

n_designs = size(design_paths, 1);
res = zeros(n_designs, 1);
for d = 1:n_designs
  d_path = deblank(design_paths(d,:));
  res(d) = sf_test_design(d_path, params);
end
return

function res = sf_test_design(d_path, params)
% tests one design
  
% Check for SPM estimated design, with estimated contrasts
D = mardo(d_path);
if ~is_spm_estimated(D)
  error('Need an SPM estimated design');
end
if ~has_contrasts(D)
  error(['Design ' d_path ' does not contain contrasts']);
end
if ~has_images(D)
  error(['Design ' d_path ' does not contain images']);
end

% try to get one F and one T contrast
Swd = fileparts(d_path);
xCon = get_contrasts(D);
stats = [xCon(:).STAT];
Ic    = []; fnames = {};
for t = 'TF'
  for c = fliplr(find(stats == t))
    F = xCon(c).Vspm;
    if ~isempty(F)
      % SPM99 = filename, SPM2 = vol_struct
      if isstruct(F), F = F.fname; end
      F = fullfile(Swd, F);
      if exist(F, 'file'), Ic = [Ic c]; fnames{end+1} = F; break, end
    end
  end
end
if isempty(Ic)
  error(['Could not find any contrast images for ' d_path]);
end

% find maximum voxel coordinate for contrasts and test
res = 1;
for c = 1:length(Ic)
  V = spm_vol(fnames{c});
  img = spm_read_vols(V);
  [mx(c) i] = max(img(:));
  xyz(:, c) = mars_utils('e2xyz', i, V.dim(1:3));
  mx_roi(c) = maroi_pointlist(struct('XYZ', xyz(:, c), ...
				     'mat', V.mat), 'vox');
  Y = get_marsy(mx_roi(c), D, 'mean');
  E = estimate(D, Y, params);
  [E n_Ic] = add_contrasts(E, D, Ic(c));
  marsS = compute_contrasts(E, n_Ic);
  fprintf('SPM statistic %7.4f; MarsBaR statistic %7.4f\n',...
	  mx(c), marsS.stat(1));
  if abs(marsS.stat(1) - mx(c)) > 1e-5
    disp('MarsBaR gives a different result for contrast');
    res = 0;
  end
end
return

