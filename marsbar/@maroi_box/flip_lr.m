function o = flip_lr(o)
% flips ROI left / right
%
% $Id$  

o.centre(1) = o.centre(1)*-1;
