function v = volume(obj)
% volume method - returns volume of ROI in mm
%
% $Id$

sp = native_space(obj);
XYZ = voxpts(obj,sp);
vox = sqrt(sum(sp.mat(1:3,1:3)'.^2));
v = size(XYZ,2) * prod(vox);