function mat = my_rld(rlem, dim)
% function to do run length decoding 
%
% $Id$

sz = sum(rlem(:,1));
mat = zeros(sz, 1);
st = 1;
for i = 1:size(rlem, 1)
  tm = zeros(rlem(i,1),1) + rlem(i,2);
  st2 = st + rlem(i,1);
  mat(st:st2-1) = tm;
  st = st2;
end