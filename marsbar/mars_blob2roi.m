function mars_blob2roi(xSPM, pt)
% saves ROI for cluster in xSPM structure, containing point pt
% FORMAT mars_blob2roi(xSPM, pt)
%
% Input
% xSPM         - SPM results structure with needed fields
%                  title
%                  XYZ   - voxel coordinates of activated points
%                  Z     - statistic values for activated points
%                  M     - 4x4 matrix from voxels to mm 
%
% $Id$

if nargin < 1
  error('Need SPM structure');
end
if nargin < 2
  error('Need point to identify cluster');
end

vx_i = spm_XYZreg('findxyz', pt, xSPM.XYZmm);
if isempty(vx_i)
  msgbox('No activated voxel at this location');
  return
end
Clusters = spm_clusters(xSPM.XYZ);
cXYZ = xSPM.XYZmm(:, Clusters==Clusters(vx_i));  
if isempty(cXYZ), return, end
d = sprintf('%s cluster at [%0.1f %0.1f %0.1f]', xSPM.title, pt);
l = sprintf('%s_%0.0f_%0.0f_%0.0f', xSPM.title, pt);
o = maroi_pointlist(struct('XYZ',cXYZ, 'mat', xSPM.M, ...
			   'label', l, 'descrip', d));
marsbar('saveroi', o);
