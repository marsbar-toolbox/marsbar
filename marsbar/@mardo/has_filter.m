function tf = has_filter(o)
% returns 1 if object contains filter
tf = 0;
if isfield(o.des_struct, 'xX')
  tf = isfield(o.des_struct.xX, 'K');
end
