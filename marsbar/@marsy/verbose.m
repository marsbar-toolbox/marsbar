function res = verbose(obj, data)
% get/set method for verbose field
%
% $Id$ 
  
if nargin > 1
  obj.verbose = data;
  res = obj;
else
  res = obj.verbose;
end