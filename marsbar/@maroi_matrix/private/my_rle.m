function rlem = my_rle(m)
% method to do run length encoding on matrix
%
% $Id$

m = m(:);
dps = [1; find(diff(m))+1];
rlem = [diff([dps; length(m)+1]), m(dps)];