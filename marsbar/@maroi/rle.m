function rlem = rle(o, sp)
% run length encoding method
%
% $Id$

if nargin < 1
  sp = native_space(o);
end
if isempty(sp)
  error('Need defined, or passed native space for run length encoding')
end

o = maroi_matrix(o, sp);
rlem = do_rle(o);