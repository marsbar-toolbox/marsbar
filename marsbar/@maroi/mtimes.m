function o = mtimes(o1, o2)
% overloaded mtimes function 
%
% $Id$

if isa(o1, 'maroi'),o1 = back2base(o1);end
if isa(o2, 'maroi'),o2 = back2base(o2);end
o = domaths('times', o1, o2);