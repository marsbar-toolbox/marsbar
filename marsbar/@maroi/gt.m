function o = gt(o1, o2)
% overloaded gt (greater than) function 
%
% $Id$

if isa(o1, 'maroi'),o1 = back2base(o1);end
if isa(o2, 'maroi'),o2 = back2base(o2);end
o = domaths('gt', o1, o2);