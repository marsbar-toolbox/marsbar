function res = y_struct(obj, Struct)
% get/set method for y_struct field
%
% $Id$ 
  
if nargin > 1
  obj.y_struct = Struct;
  res = obj;
else
  res = obj.y_struct;
end