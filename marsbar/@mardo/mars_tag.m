function res = mars_tag(o, data)
% returns, or sets, Mars tagging structure in design
% 
% $Id$
  
if nargin > 1 % set
  res = o;
  res.des_struct.xMars = data;
  return
end

if isfield(o.des_struct, 'xMars') % get
  res = o.des_struct.xMars;
else
  res = [];
end
