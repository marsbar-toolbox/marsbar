function tf = eq(sp1, sp2)
% overloaded eq method for mars_space objects
%
% $Id$

if all(sp1.dim == sp2.dim) & all((abs(sp1.mat(:) - sp2.mat(:)))< eps)
  tf = 1;
else
  tf = 0;
end