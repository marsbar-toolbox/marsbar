function v = volume(obj)
% volume method - returns volume of ROI in mm
%
% $Id$

v = (4/3*pi)*obj.radius^3;