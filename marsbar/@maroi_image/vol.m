function h = vol(obj, val)
% vol - returns / sets image vol for object
%
% $Id$

if nargin > 1
  img = my_vol_func(val, obj.func);
  obj.vol = val;
  obj = matrixdata(obj, img);
  h = obj;
else
  h = obj.vol;
end