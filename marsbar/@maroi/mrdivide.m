function o = mrdivide(o1, o2)
% overloaded mrdivide (matrix right divide) function 
%
% $Id$

if isa(o1, 'maroi'),o1 = back2base(o1);end
if isa(o2, 'maroi'),o2 = back2base(o2);end
o = domaths('divide', o1, o2);