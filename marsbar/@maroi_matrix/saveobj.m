function o = saveobj(o)
% saveobj function - does run length encoding if helpful
%
% $Id$

m = o.dat;
if isnumeric(m)
  rlem = my_rle(m);
  if prod(size(rlem)) < prod(size(m))
    o.dat = struct('rlem', rlem, 'dim', size(m));
  end
end