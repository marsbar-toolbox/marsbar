function res = test_rig(design_paths)
% runs tests on MarsBaR using specified designs
% FORMAT res = test(design_paths)
% 
% Inputs
% design_paths     - paths to SPM design files
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

res = 1;
for d = 1:size(design_paths, 1)
  d_path = deblank(design_paths(d,:));
  res = res & sf_test_design(d_path);
end
return

function res = sf_test_design(d_path)
% tests one design
  
% load design
D = mardo(d_path);

% Check for SPM estimated design, with estimated contrasts
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
swd = fileparts(d_path);
xCon = get_contrasts(D);
stats = [xCon(:).STAT];
types = 'TF';
Ic    = []; fnames = {};
for t = 1:2
  T = find(stats == types(t));
  for c = fliplr(T) % find last
    F = sf_spm_file(xCon(c).Vspm, swd);
    if ~isempty(F)
      Ic = [Ic c]; fnames{end+1} = F; break
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
  xyz(:, c) = sf_e2xyz(i, V.dim(1:3));
  mx_roi(c) = maroi_pointlist(struct('XYZ', xyz(:, c), ...
				     'mat', V.mat), 'vox');
  Y = get_marsy(mx_roi(c), D, 'mean');
  E = estimate(D, Y);
  [E n_Ic] = add_contrasts(E, D, Ic(c));
  marsS = compute_contrast(E, n_Ic);
  fprintf('SPM statistic %7.4f; MarsBaR statistic %7.4f\n',...
	  mx(c), marsS.stat(1));
  if (marsS.stat(1) - mx(c)) > 1e5
    disp('MarsBaR gives a different result for contrast');
    res = 0;
  end
end
return



function fname = sf_spm_file(fname, swd)
if isempty(fname), return, end
if isstruct(fname)
  fname = fname.fname;
end
fname = fullfile(swd, fname);
if ~exist(fname, 'file')
  fname = '';
end
return

function XYZ = sf_e2xyz(els, dim)
nz = els-1;
pl_sz = dim(1)*dim(2);
Z = floor(nz / pl_sz);
nz = nz - Z*pl_sz;
Y = floor(nz / dim(1));
X = nz - Y*dim(1);
XYZ = [X; Y;Z] +1;
return