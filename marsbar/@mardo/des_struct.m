function res = des_struct(obj, Struct)
% get/set method for des_struct field
%
% $Id$
  
if nargin > 1
  obj.des_struct = Struct;
  res = obj;
else
  res = obj.des_struct;
end