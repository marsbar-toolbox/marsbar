function o = not(o1)
% overloaded not function 
%
% $Id$

if isa(o1, 'maroi'),o1 = back2base(o1);end
o = domaths('not', o1);