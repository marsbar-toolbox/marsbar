function tf = is_empty_roi(o)
% returns 1 if ROI contains no volume
%
% $Id$

tf = isempty(o.centre);