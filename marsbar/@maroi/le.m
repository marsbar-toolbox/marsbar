function o = le(o1, o2)
% overloaded le (less than or equal to) function 
%
% $Id$

if isa(o1, 'maroi'),o1 = back2base(o1);end
if isa(o2, 'maroi'),o2 = back2base(o2);end
o = domaths('le', o1, o2);