function o = flip_lr(o)
% flips ROI left / right
%
% $Id$  

M = eye(4); M(1) = -1;
o.mat = M * o.mat;
