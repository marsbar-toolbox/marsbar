function v = volume(obj)
% volume method - returns volume of ROI in mm
%
% $Id$

v = prod(obj.widths);