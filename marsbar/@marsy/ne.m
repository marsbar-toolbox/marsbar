function tf = ne(Y1, Y2)
% method overrides ~= operator
% 
% $Id$
  
tf = ~eq(Y1, Y2);