function o = loadobj(o)
% loadobj function - undoes run length encoding if appropriate
%
% $Id$

m = o.dat;
if isfield(m, 'rlem')
  dat = my_rld(m.rlem);
  o.dat = reshape(dat, m.dim);
end