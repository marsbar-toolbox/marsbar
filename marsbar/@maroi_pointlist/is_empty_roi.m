function tf = is_empty_roi(o)
% is_empty_roi - returns true if ROI contains no volume
%
% $Id$

tf = isempty(o.XYZ);