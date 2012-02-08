function mars_img2rois(P, roipath, rootn, flags)
% creates ROIs from cluster image or image containing ROIs defined by unique nos
% FORMAT mars_img2rois(P, roipath, rootn, flags)
%
% P       - image (string or struct)
% roipath - path to directory to store ROIs
% rootn   - string to prefix to ROI filenames
% flags   - none or more of: [default = 'i']
%             'i' - id image, voxel values identify ROIs
%             'c' - cluster image, clusters identified by location
%             'x' - label clusters by location of maximum 
%                   (default is location of centre of mass)
%
% $Id$
  
if nargin < 1
  P = '';
end
if nargin < 2
  roipath = '';
end
if nargin < 3
  rootn = '';
end
if nargin < 4
  flags = ' ';
end

% Process input arguments
if any(flags == 'i')
  Pprompt = 'Image containing ROI ids';
else
  Pprompt = 'Image containing clusters';
end
if isempty(P)
  P = spm_get(1, mars_veropts('get_img_ext', Pprompt));
end
if isempty(P)
  return
end
if ischar(P)
  P = spm_vol(P);
end
if isempty(roipath)
  roipath = spm_get([-1 0], '', 'Directory to save ROIs');
end
if isempty(roipath)
  return
end
if isempty(rootn)
  [pn rootn ext] = fileparts(P.fname);
  rootn = spm_input('Prefix for ROI filenames', '+1', 's', rootn);
end
if isempty(rootn)
  return
end

if isempty(flags)
  flags = 'i';  % id image is default
end

% read img, get non-zero voxels
img = spm_read_vols(P);
img = img(:)';
dim = P.dim(1:3);
pts = find(img~=0);

% e2xyz
nz = pts-1;
pl_sz = dim(1)*dim(2);
Z = floor(nz / pl_sz);
nz = nz - Z*pl_sz;
Y = floor(nz / dim(1));
X = nz - Y*dim(1);
XYZ = [X; Y;Z] +1;

% collect clusters
vals = img(pts);

% select cluster or id 
if any(flags == 'i')
  cl_vals = vals;
else
  cl_vals = spm_clusters(XYZ);
end

for c = unique(cl_vals)
  % points for this region/cluster
  t_cl_is = find(cl_vals == c);

  % corresponding XYZ
  cXYZ = XYZ(:, t_cl_is);

  if ~isempty(cXYZ)
      % location label for cluster images
      if any(flags == 'c')
          if any(flags == 'x') % maximum 
              [mx maxi] = max(vals(t_cl_is));
              mi = t_cl_is(maxi);
              % voxel coordinate of max
              vco = XYZ(:, mi);
      else % centre of mass
          vco = mean(cXYZ, 2);
      end

      % pt coordinates in mm
      pt_lab = P.mat * [vco; 1];
      pt_lab = pt_lab(1:3);

      % file name and labels
      d = sprintf('%s cluster at [%0.1f %0.1f %0.1f]', rootn, pt_lab);
      l = sprintf('%s_%0.0f_%0.0f_%0.0f', rootn, pt_lab);

  else % id image labels from voxel values
      % file name and labels
      d = sprintf('%s: id: %d', rootn, c);
      l = sprintf('%s_%d', rootn, c);
  end

  fname = maroi('filename', fullfile(roipath, l));
  o = maroi_pointlist(struct('XYZ',cXYZ,...
  'mat',P.mat,...
  'descrip',d,...
  'label', l), ...
  'vox');
  fprintf('\nSaving %s as %s...', d, fname);
  saveroi(o, fname);
  end
end
fprintf('\nDone...\n');
