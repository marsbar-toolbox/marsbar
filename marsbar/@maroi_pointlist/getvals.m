function v = getvals(o)
% returns vals for pointlist object
%
% $Id$

if ~isempty(o.vals)
  v = o.vals;
else
  v = ones(1, size(o.XYZ,2));
end