function c = centre(obj, val)
% centre method - sets / returns centre of ROI in mm
%
% $Id$

if nargin > 1
  obj.centre = val;
end
c = obj.centre;