function mars_blobs2rois(xSPM, roipath, rootn)
% creates ROIs from spm_results_ui SPM
% FORMAT mars_blobs2rois(xSPM, roipath, rootn)
%
% Inputs
% xSPM         - SPM results structure with needed fields
%                  title
%                  XYZ   - voxel coordinates of activated points
%                  Z     - statistic values for activated points
%                  M     - 4x4 matrix from voxels to mm
% roipath      - directory in which to write ROIs
% rootn        - root name for ROI(s)

if nargin < 1
  error('Need SPM structure');
end
if nargin < 2
  roipath = '';
end
if nargin < 3
  rootn = '';
end

if isempty(roipath)
  roipath = spm_get([-1 0], '', 'Directory to save ROI(s)');
end
if isempty(roipath)
  return
end
if isempty(rootn)
  rootn = mars_utils('str2fname', xSPM.title);
  rootn = spm_input('Root name for clusters', '+1', 's', rootn);
end

pre_ones = ones(1, size(xSPM.XYZ,2));
clusters = spm_clusters(xSPM.XYZ);
[N Z maxes A] = spm_max(xSPM.Z,xSPM.XYZ);

for c = unique(A(:)')
  % maximum maximum for this cluster
  tmp = Z; tmp(A~=c) = -Inf; 
  [tmp mi] = max(tmp);
  % voxel coordinate of max
  vco = maxes(:, mi);
  % in mm
  maxmm = xSPM.M * [vco; 1];
  maxmm = maxmm(1:3);
  % corresponding cluster in spm_clusters, XYZ for cluster
  my_c = clusters(all(xSPM.XYZ == vco * pre_ones));
  XYZ = xSPM.XYZ(:, clusters == my_c(1));
  if ~isempty(XYZ)
    % file name and labels
    d = sprintf('%s cluster at [%0.1f %0.1f %0.1f]', rootn, maxmm);
    l = sprintf('%s_%0.0f_%0.0f_%0.0f', rootn, maxmm);
    fn = mars_utils('str2fname', l);
    fname = maroi('filename', fullfile(roipath, fn));
    o = maroi_pointlist(struct('XYZ',XYZ,'mat',xSPM.M,...
        'descrip',d, 'label', l), ...
        'vox');
    fprintf('\nSaving %s as %s...', d, fname);
    saveroi(o, fname);
  end
end
fprintf('\nDone...\n');
