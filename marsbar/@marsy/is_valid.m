function tf = is_valid(o)
% method returns 1 if object contains valid data
% 
% $Id$

st = y_struct(o);
tf = isfield(st, 'Y') | isfield(st, 'regions');