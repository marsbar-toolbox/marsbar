function o = saveobj(o)
% saveobj method - removes matrix information from parent to save space
%
% $Id$

o = matrixdata(o, []);